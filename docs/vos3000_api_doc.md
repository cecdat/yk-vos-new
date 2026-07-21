# VOS3000 WebExternal API 接口文档

> 来源：`http://8.130.185.103:9090/external/test/server/`
> 文档生成时间：2026-07-21

---

## 1. 概述

VOS3000 WebExternal 是昆石网络（Kunshi）VOS3000 软交换系统的外部接口模块，允许第三方系统通过 HTTP 接口管理电话号码、查询话单等。

本文档通过逆向分析测试页面 `http://8.130.185.103:9090/external/test/server/` 的前端 JS 代码（Vue.js SPA）并结合实际 API 调用验证后整理而成。

**测试环境信息：**

| 项目 | 地址 |
|------|------|
| 测试页面 | `http://8.130.185.103:9090/external/test/server/` |
| API 基地址 | `http://8.130.185.103:9090/external/server/` |
| 内网测试后端（TEST_SERVLET_PREFIX） | `http://172.16.5.142:8888/external/server/`（外网不可达） |

---

## 2. 系统架构

测试页面是一个 Vue.js 单页应用（产品名 `VosWebexternal`），工作流程如下：

1. 页面加载时调用 `POST /external/server/GetInterfaceList` 获取可用接口列表
2. 用户选择某个接口后，从 `interfaces/{接口名}.json` 加载该接口的参数定义
3. 用户填写参数后，调用 `POST /external/server/{接口名}` 执行接口
4. 返回 JSON 格式的响应结果

前端代码关键配置：

```javascript
// $common 配置对象
var ve = {
    PRODUCT_ID: "VosWebexternal",
    SERVLET_PREFIX: "../../",           // 生产环境：相对路径
    TEST_SERVLET_PREFIX: "http://172.16.5.142:8888/external/server/",  // 本地开发
    // ...
};

// servletPrefix 计算方式
servletPrefix = SERVLET_PREFIX + getContextName() + "/";
// 对于 URL /external/test/server/ → getContextName() = "server"
// 最终 servletPrefix = "../../server/" → 解析为 /external/server/
```

---

## 3. 通用约定

### 请求格式

| 项目 | 说明 |
|------|------|
| HTTP 方法 | `POST` |
| Content-Type | `application/x-www-form-urlencoded;charset=UTF-8` |
| 请求体 | JSON 字符串（通过 `JSON.stringify()` 序列化） |
| URL 格式 | `POST /external/server/{接口名}` |

### 响应格式

所有接口返回 JSON 格式数据，核心字段如下：

| 字段 | 类型 | 说明 |
|------|------|------|
| `retCode` | Integer | 返回码，`0` 表示成功，负数表示错误 |
| `exception` | String | 错误描述（仅错误时返回） |
| 其他字段 | — | 接口特定的返回数据 |

### 支持的数据类型

| 类型 | 说明 | 示例值 |
|------|------|--------|
| String | 字符串 | `"800801"` |
| String[] | 字符串数组 | `["800801", "800802"]` |
| Integer / int | 整数 | `100` |
| Long / long | 长整数 | `1000000` |
| Float / float | 浮点数 | `3.14` |
| Double / double | 双精度浮点 | `3.14159` |
| Boolean / boolean | 布尔值 | `true` / `false` |
| Byte / byte | 字节 | `1` |
| Short / short | 短整数 | `100` |
| char | 字符 | `"A"` |

**类型转换规则（dataFormatter）：**

- 包装类型（Integer/Long/Float/Double/Byte/Short）：解析失败返回 `null`
- 基本类型（int/long/float/double/byte/short）：解析失败返回 `0`
- Boolean：`true` 或 `"true"` 为真，其余为假
- boolean：仅 `true` 或 `"true"` 为真，其余为假

---

## 4. 错误码

通过实际调用验证发现的错误码：

| retCode | 含义 | 触发场景 |
|---------|------|---------|
| `0` | 成功 | 请求正常处理 |
| `-12103` | 缺少参数（Miss parameters） | 未传入必填参数 |
| `-10124` | 输入参数错误（Input parameter error） | 参数格式或值不正确 |
| `-10033` | 查询间隔超限（Over the limitation of inquiry interval） | CDR 查询时间范围过大 |

---

## 5. DeletePhone — 删除电话号码

**接口说明：** 根据 E.164 号码删除指定的电话号码记录。

```
POST /external/server/DeletePhone
```

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `e164` | String | 必填 | 要删除的电话号码（E.164 格式） |

**请求示例：**

```json
{
    "e164": "800801"
}
```

**响应示例（成功）：**

```json
{
    "retCode": 0
}
```

**实际调用验证：**

```bash
curl -X POST "http://8.130.185.103:9090/external/server/DeletePhone" \
  -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
  -d '{"e164":"800801"}'

# 响应
{"retCode":0}
```

---

## 6. GetPhone — 查询电话号码

**接口说明：** 根据 E.164 号码或账户名查询电话号码信息。至少需要传入一个查询条件。

```
POST /external/server/GetPhone
```

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `e164s` | String[] | 可选 | 要查询的电话号码数组（E.164 格式） |
| `accounts` | String[] | 可选 | 要查询的账户名数组 |

> **注意：** 虽然两个参数都标记为可选，但至少需要传入一个，否则返回错误码 `-12103`（Miss parameters）。

**请求示例：**

```json
{
    "e164s": ["800801"],
    "accounts": ["800801"]
}
```

**响应示例（成功，无数据）：**

```json
{
    "retCode": 0,
    "infoPhones": []
}
```

**响应字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `retCode` | Integer | 返回码 |
| `infoPhones` | Array | 电话号码信息数组 |

**实际调用验证：**

```bash
# 正常调用
curl -X POST "http://8.130.185.103:9090/external/server/GetPhone" \
  -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
  -d '{"e164s":["800801"],"accounts":["800801"]}'

# 响应
{"retCode":0,"infoPhones":[]}

# 空参数调用 → 返回错误
curl -X POST "http://8.130.185.103:9090/external/server/GetPhone" \
  -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
  -d '{}'

# 响应
{"retCode":-12103,"exception":"Miss parameters"}
```

---

## 7. GetCdr — 查询话单（CDR）

**接口说明：** 查询指定账户在指定时间范围内的话单记录（Call Detail Record）。支持按主叫/被叫号码和网关进行过滤。

```
POST /external/server/GetCdr
```

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `accounts` | String[] | 必填 | 要查询的账户名数组 |
| `callerE164` | String | 可选 | 主叫号码（E.164 格式），用于过滤 |
| `calleeE164` | String | 可选 | 被叫号码（E.164 格式），用于过滤 |
| `callerGateway` | String | 可选 | 主叫网关名称，用于过滤（如 `mappingGateway`） |
| `calleeGateway` | String | 可选 | 被叫网关名称，用于过滤（如 `routingGateway`） |
| `beginTime` | String | 必填 | 查询开始时间，格式：`yyyyMMdd`（如 `20260720`） |
| `endTime` | String | 必填 | 查询结束时间，格式：`yyyyMMdd`（如 `20260721`） |

> **查询间隔限制：** 系统对 CDR 查询的时间范围有限制，如果 `beginTime` 到 `endTime` 的间隔过大，将返回错误码 `-10033`（Over the limitation of inquiry interval）。需联系系统管理员调整限制。

**请求示例：**

```json
{
    "accounts": ["800801"],
    "callerE164": "800801",
    "calleeE164": "800801",
    "callerGateway": "mappingGateway",
    "calleeGateway": "routingGateway",
    "beginTime": "20260720",
    "endTime": "20260721"
}
```

**响应示例（成功，无数据）：**

```json
{
    "retCode": 0,
    "infoCdrs": []
}
```

**响应字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `retCode` | Integer | 返回码 |
| `infoCdrs` | Array | 话单记录数组，包含通话详情 |
| `exception` | String | 错误描述（仅错误时返回） |

**实际调用验证：**

```bash
# 正常调用（间隔 1 天）
curl -X POST "http://8.130.185.103:9090/external/server/GetCdr" \
  -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
  -d '{"accounts":["800801"],"beginTime":"20260720","endTime":"20260721"}'

# 响应
{"retCode":0,"infoCdrs":[]}

# 间隔过大 → 返回错误
curl -X POST "http://8.130.185.103:9090/external/server/GetCdr" \
  -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
  -d '{"accounts":["800801"],"beginTime":"20190101","endTime":"20260721"}'

# 响应
{"retCode":-10033,"exception":"Over the limitation of inquiry interval, please contact system administrator","infoCdrs":[]}

# 空参数 → 返回错误
curl -X POST "http://8.130.185.103:9090/external/server/GetCdr" \
  -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
  -d '{}'

# 响应
{"retCode":-10124,"exception":"Input parameter error","infoCdrs":[]}
```

---

## 8. GetInterfaceList — 获取接口列表

**接口说明：** 获取当前 VOS3000 系统中可用的外部接口列表。

```
POST /external/server/GetInterfaceList
```

**请求参数：** 无参数（发送空请求体）

**响应格式（预期）：**

```json
// 返回接口名称数组
["DeletePhone", "GetPhone", "GetCdr", ...]
```

> **注意：** 在当前测试环境中，该接口返回 HTTP 200 但响应体为空（Content-Length: 0），可能是未配置认证会话或系统未完全初始化。在正常 VOS3000 生产环境中，此接口应返回所有可用接口名称的数组。

---

## 9. 完整调用示例

### curl

```bash
# 查询电话号码
curl -X POST "http://8.130.185.103:9090/external/server/GetPhone" \
  -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
  -d '{"e164s":["800801"]}'

# 查询话单
curl -X POST "http://8.130.185.103:9090/external/server/GetCdr" \
  -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
  -d '{"accounts":["800801"],"beginTime":"20260720","endTime":"20260721"}'

# 删除电话号码
curl -X POST "http://8.130.185.103:9090/external/server/DeletePhone" \
  -H "Content-Type: application/x-www-form-urlencoded;charset=UTF-8" \
  -d '{"e164":"800801"}'
```

### Python

```python
import requests
import json

BASE_URL = "http://8.130.185.103:9090/external/server"
HEADERS = {"Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"}

# 查询电话号码
resp = requests.post(f"{BASE_URL}/GetPhone",
    data=json.dumps({"e164s": ["800801"]}), headers=HEADERS)
print(resp.json())  # {"retCode": 0, "infoPhones": []}

# 查询话单
resp = requests.post(f"{BASE_URL}/GetCdr",
    data=json.dumps({
        "accounts": ["800801"],
        "beginTime": "20260720",
        "endTime": "20260721"
    }), headers=HEADERS)
print(resp.json())  # {"retCode": 0, "infoCdrs": []}

# 删除电话号码
resp = requests.post(f"{BASE_URL}/DeletePhone",
    data=json.dumps({"e164": "800801"}), headers=HEADERS)
print(resp.json())  # {"retCode": 0}
```

### Java (OkHttp)

```java
OkHttpClient client = new OkHttpClient();

String json = "{\"e164s\":[\"800801\"]}";
RequestBody body = RequestBody.create(json,
    MediaType.parse("application/x-www-form-urlencoded;charset=UTF-8"));

Request request = new Request.Builder()
    .url("http://8.130.185.103:9090/external/server/GetPhone")
    .post(body)
    .build();

Response response = client.newCall(request).execute();
System.out.println(response.body().string());
// {"retCode":0,"infoPhones":[]}
```

---

*VOS3000 WebExternal API 文档 | 基于 http://8.130.185.103:9090/external/test/server/ 逆向分析 | 2026-07-21*
