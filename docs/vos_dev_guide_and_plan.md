# VOS3000 数据中台功能设计、开发指导手册与项目排期计划

本文件作为 YK-VOS 数据中台二期核心功能开发的技术指引、功能设计与项目管理基准。所有前后端开发人员在编码和页面设计过程中必须严格遵守本规范，可直接根据本指南执行开发与代码实现。

---

## 一、 架构设计核心原则与开发注意事项

为确保 VOS3000 服务器的运行安全与稳定性，避免高频呼叫期间受外部管理查询的干扰，本项目中台架构遵循以下核心原则：

### 1. 查询 100% 隔离（读链路走本地库）
* 所有前端页面的数据呈现（包括**历史话单检索、利润对账报表、客户账户列表、网关并发水位监控**等），必须全部读取中台本地的 ClickHouse 或 MySQL 镜像库。
* **严禁在中台直接发起批量查询请求至 VOS 官方的 WebExternal 接口**，以避开官方接口调用频次与天数跨度限制，降低 VOS 节点的运行负荷。

### 2. 新增/修改 100% 走官方 API（写链路走 API 控制）
* 为保证 VOS 运行期内存缓存与通话路由引擎的数据一致性，任何涉及到**新增、删除、修改配置**的操作（如号码解绑/回收、号码导入、网关限额扩容、账户冻结），**严禁直接 SQL 物理更新 VOS 生产库的配置表**。
* 中台将修改操作打包成指令发送至 Kafka，由 VOS 节点上的 Go Agent 消费后，在本地请求 VOS 的 WebExternal API 接口（如 `/DeletePhone`），由 VOS 本地处理内存热重载与本地 MySQL 持久化。

### 3. 前端 UI 规范（禁用 Emoji 表情）
* **禁止在前端（Vue3 / Element Plus）页面中使用任何 Emoji 图标**（如 `🔴`, `🟢`, `📋`, `📊`, `⚙️` 等）作为标题、按钮、文本修饰或状态标示。
* **统一图标库**：所有图标及状态标识一律采用项目内置的 **Iconify/Lucide 图标库**进行渲染（如 `<IconifyIcon icon="lucide:clipboard-list" />`），以保持企业后台的专业严谨性。

---

## 二、 模块联动与业务闭环原理 (CQRS & Linkage Logic)

中台不仅是数据的展示窗口，更承载着跨模块的安全控制联动：

```
                    ┌─────────────────────────┐
                    │  ClickHouse 话路质量监控 │
                    └────────────┬────────────┘
                                 │ 挂断率异常 / PDD 延时飙升
                                 ▼
┌────────────────────────┐  联动阻断  ┌────────────────────────┐
│   对接/落地网关并发水位 │ ─────────► │ 号码资产/路由回收删除   │
│   (Element 进度条监控)  │            │ (调用 VOS DeletePhone)  │
└────────────────────────┘            └────────────────────────┘
            ▲                                      ▲
            │ 扣费引发余额不足                       │ 号码回收同步删除
            │                                      │
┌────────────────────────┐            ┌────────────┴───────────┐
│     客户可用余额控制    │ ─────────► │ VOS 本地 MySQL 与内存   │
│   (余额 <= 信用额度)    │  一键冻结  │ 路由状态更新            │
└────────────────────────┘            └────────────────────────┘
```

### 1. 客户余额与网关呼叫阻断联动
* **联动机制**：每个客户账户的呼叫通过特定对接网关接入。当计费模块从话单流水累计扣减余额，导致客户可用余额低于信用额度（`money <= limitmoney`）时，中台风控服务检测到后将自动调用 VOS 控制接口，触发 `SET_STATUS` 指令锁定该客户（`status = 1`）。
* **VOS 侧联动表现**：VOS 本地接收到账户锁定指令后，会瞬间拒绝来自该客户对接网关的所有新呼叫请求，已在通话中的信道将根据 VOS 系统配置在 30 秒至 1 分钟内强行挂断，实现物理级话路切断，杜绝恶意刷单和欠费损失。

### 2. 号码解绑回收与网关活动信道联动
* **联动机制**：当管理员在“号码资产管理”页面选中号码 `800801` 并执行“回收删除”时，中台向 Agent 下发 `DeletePhone` API 调用指令。
* **VOS 侧联动表现**：WebExternal 接口被调用后，VOS 核心路由引擎会在**内存中瞬间卸载**挂载在该号码上的主/被叫路由映射，并向占用该号码信道的正在通话流发送 `BYE` 挂断信号，活动话单立刻中止结算，网关并发占用数同步下摆释放。

---

## 三、 数据层接口规则与参数约定 (API Rules)

### 1. 统一接口响应规范
所有数据中台面向前端的 HTTP 接口返回数据结构遵循 Ruoyi-Vue-Pro 的 `CommonResult` 标准：
```json
{
  "code": 0,          // 0 表示成功，非 0 表示系统级或业务级错误
  "msg": "",          // 错误信息描述
  "data": {}          // 业务响应体
}
```

### 2. 时间精度与格式约定
* **前端传入参数**：时间筛选器必须为 `type="datetime"`，传给后端的字段统一为 `YYYY-MM-DD HH:mm:ss`（例如 `"2026-07-21 23:59:59"`）。
* **接口数据处理**：前端通过 `formatYmd` 清洗发送时，日期中的横杠会被剔除（即 `"20260721 23:59:59"`）。
* **后端解析策略**：后端 `parseTimeToMillis` 必须兼容包含空格和冒号的 `yyyyMMdd HH:mm:ss`，并转化为 Unix 毫秒时间戳与 ClickHouse 中的 `recordstarttime`（`Int64` 毫秒级）对齐。
* **列表展现格式**：从 ClickHouse 读出的时间戳字段，前端一律通过 `formatTs` 转换为 `yyyy-MM-dd HH:mm:ss`，精确到秒。

---

## 四、 Kafka 指令协议规范 (Kafka Command Payload Schema)

控制通道主题统一为：`vos.control`，生产者与消费者交互的消息体格式采用 JSON 封装，核心参数规范如下：

### 1. 修改信用额度 (`UPDATE_LIMIT`)
* **适用场景**：对指定客户进行可用透支信用额度的上调或下调。
* **Kafka 消息荷载 (Payload)**：
  ```json
  {
    "vosId": "vos1",
    "timestamp": 1784678399000,
    "cmd": "UPDATE_LIMIT",
    "data": {
      "customerId": 101,
      "account": "CECDAT_SIP",
      "limitmoney": -1000.00
    }
  }
  ```

### 2. 冻结/解冻客户账户 (`SET_STATUS`)
* **适用场景**：因欠费阻断或手动管控，锁定/解锁指定账户。
* **Kafka 消息荷载 (Payload)**：
  ```json
  {
    "vosId": "vos1",
    "timestamp": 1784678399000,
    "cmd": "SET_STATUS",
    "data": {
      "customerId": 101,
      "account": "CECDAT_SIP",
      "status": 1                 // 0: 正常/激活, 1: 冻结/挂起
    }
  }
  ```

### 3. 号码回收/删除 (`RECYCLE_PHONE`)
* **适用场景**：从网关上批量卸载并删除 E.164 电话号码。
* **Kafka 消息荷载 (Payload)**：
  ```json
  {
    "vosId": "vos1",
    "timestamp": 1784678399000,
    "cmd": "RECYCLE_PHONE",
    "data": {
      "e164s": ["800801", "800802"]
    }
  }
  ```

---

## 五、 开发者 ClickHouse SQL 实现参考 (ClickHouse SQL Blueprints)

开发者在实现控制层和报表统计服务时，可直接参考并复用以下高吞吐 SQL 原型：

### 1. 客户/供应商多维利润及对账统计（模块二）
* **SQL 逻辑说明**：利用 ODS 话单表的 `fee`（接入收入）与 `agentfee`（落地成本）直接在 ClickHouse 侧进行秒级聚合，过滤通话时间范围，计算出净利润与毛利率。
* **SQL 代码**：
  ```sql
  SELECT
      customeraccount AS account,
      count() AS callCount,
      sum(feetime) / 60 AS billingDurationMinutes,
      sum(fee) AS revenue,
      sum(agentfee) AS cost,
      sum(fee) - sum(agentfee) AS profit,
      if(sum(fee) > 0, round((sum(fee) - sum(agentfee)) / sum(fee) * 100, 2), 0.0) AS profitRate
  FROM ykvos_ch.vos_cdr_ods
  WHERE vos_id = 'vos1'
    AND recordstarttime BETWEEN 1783958400000 AND 1784678399999
  GROUP BY customeraccount
  ORDER BY profit DESC;
  ```

### 2. 网关负载并发实时统计（模块三）
* **SQL 逻辑说明**：根据未挂断话单（即 `stoptime = 0` 或没有收到挂断事件的话单数）统计各网关的当前活跃呼叫数。
* **SQL 代码**：
  ```sql
  SELECT
      calleegatewayid AS gatewayName,
      count() AS activeCalls
  FROM ykvos_ch.vos_cdr_ods
  WHERE vos_id = 'vos1'
    AND stoptime = 0 -- 通话尚未结束，即为活动并发
  GROUP BY calleegatewayid;
  ```

### 3. 网关质量 KPI (ASR/ALOC) 分析
* **SQL 代码**：
  ```sql
  SELECT
      calleegatewayid AS gatewayName,
      count() AS totalCalls,
      countIf(feetime > 0) AS answeredCalls,
      round(countIf(feetime > 0) / count() * 100, 2) AS asr, -- 接通率
      if(countIf(feetime > 0) > 0, round(sum(feetime) / countIf(feetime > 0), 0), 0) AS aloc -- 平均通话时长(秒)
  FROM ykvos_ch.vos_cdr_ods
  WHERE vos_id = 'vos1'
  GROUP BY calleegatewayid;
  ```

---

## 六、 Go Agent 与 WebExternal 本地代理对接细节 (Go Agent & HTTP Call)

Go Agent 在 VOS 节点本地执行配置更新时，其工作细节必须满足以下规定：

### 1. HTTP 交互协议
* **目标基地址**：`http://127.0.0.1:9090/external/server/{ActionName}`
* **请求头**：
  * `Content-Type: application/x-www-form-urlencoded;charset=UTF-8`
* **接口认证说明**：
  * VOS3000 WebExternal 采用基于 IP 白名单机制进行鉴权，Agent 直接部署在 VOS 本机通过 `127.0.0.1` 环回接口通信，天然免除账号登录会话，极大简化了控制流程，提高了指令下发成功率。

### 2. 接口参数与执行体示例 (以号码解绑为例)
Go Agent 接收到 `RECYCLE_PHONE` 消息后，将以批量/单条方式调用 VOS 节点上的本地 HTTP 接口：
```go
// 伪代码示例：Go Agent 本地向 VOS HTTP 发起号码删除
func deleteE164(e164 string) (bool, error) {
    url := "http://127.0.0.1:9090/external/server/DeletePhone"
    
    // 组装 VOS WebExternal 格式的请求参数：JSON String
    params := map[string]string{
        "e164": e164,
    }
    jsonData, _ := json.Marshal(params)
    
    // 发送 x-www-form-urlencoded 请求，Body 为上面序列化后的 JSON 字符串
    resp, err := httpClient.Post(url, "application/x-www-form-urlencoded;charset=UTF-8", bytes.NewBuffer(jsonData))
    if err != nil {
        return false, err
    }
    defer resp.Body.Close()
    
    // 解析返回 JSON
    var vosResult struct {
        RetCode   int    `json:"retCode"`
        Exception string `json:"exception"`
    }
    json.NewDecoder(resp.Body).Decode(&vosResult)
    
    if vosResult.RetCode == 0 {
        return true, nil // 执行成功，内存与库已同步生效
    }
    return false, fmt.Errorf("vos error: %s (code: %d)", vosResult.Exception, vosResult.RetCode)
}
```

---

## 七、 前后端开发目录指引

* **前端视图代码**：`frontend/apps/web-ele/src/views/vos/`
  * 客户管理：`vos/customer/index.vue`
  * 网关监控：`vos/gateway/index.vue`
  * 号码管理：`vos/phone/index.vue`
  * 话单对账：`vos/report/index.vue`
* **前端 API 请求层**：`frontend/apps/web-ele/src/api/vos.ts`
* **后端控制器 (Controller)**：`cn.iocoder.yudao.module.vos.controller.admin.vos`
* **后端服务 (Service)**：`cn.iocoder.yudao.module.vos.service`
* **控制指令传输层 (Kafka)**：
  * 后端发布端：`AgentControlProducer.java`
  * Agent 接收端：`agent/internal/consumer/control_consumer.go`

---

## 八、 项目版本发布管理与开发排期进度

### 1. 严格版本升级管理规范
在编译打包生成部署包时，**严禁使用重复的版本号**。每次打包必须递增 Patch（修订号），确保环境升级自愈。
* **当前基线**：`1.0.4`
* 里程碑一发布包：`ykvos-server-dev-1.0.5.tar.gz`
* 里程碑二发布包：`ykvos-server-dev-1.0.6.tar.gz`
* 里程碑三发布包：`ykvos-server-dev-1.0.7.tar.gz`
* 里程碑四发布包：`ykvos-server-dev-1.0.8.tar.gz`

### 2. 里程碑与详细开发排期进度

```mermaid
gantt
    title 数据中台二期核心功能开发排期
    dateFormat  YYYY-MM-DD
    section 第一阶段：数据采集、扩展与菜单SQL (v1.0.5)
    Go Agent 客户定时增量提取             :active, 2026-07-22, 2d
    VosInstanceDO 注解与字段扩展           :active, 2026-07-23, 2d
    初始化菜单 SQL 与 visible 属性覆盖      :active, 2026-07-24, 1d
    section 第二阶段：反向控制 Kafka 与 API 联调 (v1.0.6)
    Kafka 控制面发送与 Agent API 请求实现  : 2026-07-25, 3d
    客户调额与状态锁定控制接口对接         : 2026-07-28, 4d
    section 第三阶段：客户管理与财务对账页面 (v1.0.7)
    客户财务管理前端页面编写(无Emoji规范)  : 2026-08-01, 3d
    对账、成本、利润三合一报表页面编写     : 2026-08-04, 3d
    section 第四阶段：网关并发监控与号码管理 (v1.0.8)
    活动并发水位读取与 Element 进度条渲染  : 2026-08-07, 3d
    号码资产批量绑定与解绑 API 联调       : 2026-08-10, 3d
    系统级测试、Bug修复与最终版 1.0.8 交付  : 2026-08-13, 4d
```
