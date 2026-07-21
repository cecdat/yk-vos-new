# YK-VOS 测试环境（dev）部署 Runbook

本目录为**自包含**交付物，合并了「数据底座」+「应用层（前后端）」，可直接拷到测试服务器运行。

## 交付物清单（已打包）
| 包 | 路径 | 说明 |
|---|---|---|
| **Agent（VOS 侧）** | `agent/ykvos-agent-1.0.6.tar.gz` | 装到每台 VOS 服务器，含二进制 + install.sh + init.d + 看门狗 + 配置样例 |
| **服务侧（平台/测试服务器）** | `ykvos-server-dev-1.0.6.tar.gz` | 整个 dev 栈：docker-compose + 数据底座(CH/Kafka/monitor/init) + 应用层(MySQL/Redis/backend/frontend) + 拉取客户端 |

> 服务侧包内已含 agent 包，无需另行取。解包即得到本目录结构。

## 0. 前提
- 镜像源（用户指定）：多数用 `docker.1ms.run/...`（clickhouse / bitnami/kafka / mysql / redis / nginx）；后端用 `pinny3/openjdk21:latest`（Docker Hub，非 1ms 源）、前端用 `docker.1ms.run/nginx:latest`。若某镜像拉取失败，去掉 `docker.1ms.run/` 前缀用官方源即可。
- 每台 VOS 服务器有公网、装有 `ykvos-agent`（见 §3）。
- 测试服务器**无公网端口** → 平台侧出站拉取；查看监控页用 SSH 隧道。

## 1. 起全栈（含数据端自动初始化）
```bash
cd release/dev
cp .env.example .env
vi .env                      # 填各 VOS 节点公网 IP：NODES=vos1=http://<IP1>:5233,vos2=http://<IP2>:5233

docker compose up -d           # 起全部（mysql/redis 先初始化，backend 等其 healthy 再起）
```
- **MySQL**：首次启动自动导入 `backend/sql/mysql/` 下全部 `*.sql`：`quartz.sql` + `ykvos.sql`（yudao 基座建库）+ `vos.sql`（VOS 4 张表，`CREATE TABLE IF NOT EXISTS`）+ `vos_menu.sql` / `vos_role_seed.sql`（菜单 / 角色 / 套餐种子，`INSERT IGNORE` 幂等）。
- **ClickHouse**：`clickhouse-init` 健康后自动跑 `01_ods_vos.sql` + `02_kafka_ingest.sql`（建 ODS 表 + Kafka MV，幂等）。
- **Kafka**：`kafka-init` 自动建 topic `vos.cdr.live`（幂等）。
- **数据全部落在本地目录** `release/dev/data/{mysql,redis,clickhouse,kafka,backend-logs}/`（不再用命名卷）。容器删了数据仍在。
- 验证：`docker ps` 应见 `yk-mysql`/`yk-redis` healthy、`yk-backend`/`yk-frontend` up、`yk-clickhouse`/`yk-kafka`/`yk-monitor` up；各 `*-init` 为 `restart:no`，跑完 Exit 0。

## 1.2 VOS 模块数据初始化（补建 / 重跑）
`backend/sql/mysql/` 挂载进 MySQL 容器的 `/docker-entrypoint-initdb.d`，**库首次创建时**会自动按顺序执行全部 `*.sql`（见上 MySQL 条）。

⚠️ 该自动机制**只在 MySQL 数据目录为空（首次 `docker compose up`）时跑一次**。若库已存在（例如先装了标准 yudao、再补 VOS 模块），需手动补建 VOS 数据：
```bash
cd release/dev
# 方式 A（推荐，免映射端口）：在 compose 网络内执行
docker compose exec mysql bash /init/init-mysql-vos.sh
# 方式 B：本机直连（需临时给 mysql 加 ports:["3306:3306"] 或用 SSH 隧道）
MYSQL_HOST=127.0.0.1 MYSQL_PORT=3306 \
  MYSQL_USER=root MYSQL_PASSWORD=123456 \
  bash init/init-mysql-vos.sh
```
脚本仅执行 VOS 专属的 3 个 SQL（`vos.sql` / `vos_menu.sql` / `vos_role_seed.sql`），且全部幂等（建表 `IF NOT EXISTS` + 种子 `INSERT IGNORE`），**重复执行安全**。

## 1.5 更新部署（清理旧文件）
发布包自带清理脚本 `cleanup.sh`，更新前执行即可清掉所有「跟随新包走的可重建文件」，
**仅保留数据映射目录 `./data`（MySQL/ClickHouse/Kafka/日志）与运行时配置 `.env`**（新包不含 `.env`，删了需重填）。
```bash
cd release/dev
bash cleanup.sh            # 交互确认后删除；会先 docker compose down 释放挂载
# 或：bash cleanup.sh --force   （跳过确认）
# 或：bash cleanup.sh --dry-run （只列出将删内容，不实际删除）

# 清理后，把新的压缩包内容解压到本目录，再：
docker compose up -d
```
脚本安全保护：仅当目录内存在 `docker-compose.yaml` 才执行，防误删。

## 2. 访问前后端与端口规划（最小暴露）
本编排遵循「非必要端口不对外映射，容器内用服务名互通」。**对外仅 2 个端口**：

| 端口 | 服务 | 面向 | 说明 |
|---|---|---|---|
| **3000** | frontend(nginx) | 用户浏览器 | 唯一的人机访问入口；反代 `/admin-api` → `backend:48080` |
| **3001** | kafka(EXTERNAL) | VOS 节点 agent | 【推送模式】agent 出站推话单的入口（host 3001 → 容器 3001）；其余服务不对外 |

其余服务（backend:48080 / mysql:3306 / redis:6379 / clickhouse:8123,9000 / monitor:8088）**均不对外**，仅容器内用服务名互通。需临时调试时，在对应服务下临时加 `ports` 即可。

- **前端管理后台**：浏览器开 `http://<测试服务器IP>:3000`。
- **默认管理员账号**：`admin` / `admin123`（yudao 内置，首次登录后请改密）。
- **后端 API**：容器内 `backend:48080/admin-api`；前端同源反代，无需对外暴露 48080。
- **监控页**：默认不对外，看链路健康时临时给 monitor 加 `ports:["18088:8088"]` 或用 SSH 隧道。

### 推送模式（agent → 服务端 Kafka）
- 数据链路：`VOS 本机 agent（出站）→ 服务端 Kafka:3001 → ClickHouse Kafka 引擎消费 → vos_cdr_ods`。
- **关键**：`.env` 里的 `YK_KAFKA_ADVERTISED_HOST` 必须填「VOS 的 agent 能访问到的服务端 IP/域名」，否则 agent 连不进来。本部署默认已设 `120.226.208.2`（服务端对 VOS 暴露地址），如需改在 `.env` 覆盖。
- agent 端 `config.yaml`：`sync.mode: kafka`、`server.listen: ""`（不起入站端点）、`kafka.brokers: ["120.226.208.2:3001"]`。
- 服务端防火墙/安全组只需放行入站 **3001**（给 VOS）和 **3000**（给用户）。

## 3. 平台侧拉取（验证数据闭环）
```bash
# 直写 ClickHouse（最快验证，零依赖）
python3 tools/pull_client.py \
  --agent-url http://<VOS1公网IP>:5233 \
  --clickhouse http://127.0.0.1:18123 --once

# 多节点：--agent-url 可重复
python3 tools/pull_client.py \
  --agent-url http://<VOS1公网IP>:5233 \
  --agent-url http://<VOS2公网IP>:5233 \
  --clickhouse http://127.0.0.1:18123

# 或经本机 Kafka 中继（与生产消费者侧一致）
python3 tools/pull_client.py --sink kafka --agent-url http://<IP1>:5233
```
验证：`docker exec -i yk-clickhouse clickhouse-client -m -q "SELECT vos_id,count() FROM vos_cdr_ods GROUP BY vos_id"`

## 4. VOS 侧装 agent（每台节点）
```bash
# 拷 agent/ 下 ykvos-agent-1.0.6.tar.gz 到 VOS 服务器
tar -xzf ykvos-agent-1.0.6.tar.gz && cd ykvos-agent-1.0.6
sudo bash install.sh

# 改 /opt/ykvos-agent/etc/config.yaml：
#   instance.id: "vos1"            # 须与 .env 里 NODES 的 name 一致
#   mysql.user: "vosdev"          # 测试账号（生产请换专用只读账号）
#   sync.mode: "off"              # 测试拓扑：不起 Kafka 推送，只起 HTTP 拉取端点
#   server.listen: ":5233"
#   export YK_MYSQL_PWD='21Hnykxx@2026'   # 测试密码；生产务必轮换、走密钥库
sudo systemctl restart ykvos-agent
```
> ⚠️ `vosdev` / `21Hnykxx@2026` 仅为**测试环境**凭据，生产必须替换为独立只读账号并定期轮换。

## 5. 看监控页（链路健康 / lag）
测试服务器无公网端口，本机用 SSH 隧道转发：
```bash
ssh -L 18088:127.0.0.1:18088 user@<平台测试服务器>
# 浏览器开 http://127.0.0.1:18088
```
页面每 15s 自动刷新，按 `vos_id` 分节点展示：各节点 agent 的 `/healthz`、`/v1/watermark`；ClickHouse 各 `vos_id` 已落库行数 / 最后同步时间 / **lag = agent 水位 − CH 水位**。

## 6. 目录说明
| 路径 | 作用 |
|---|---|
| `docker-compose.yaml` | **合并编排**：数据底座(CH+Kafka+monitor+init) + 应用层(mysql+redis+backend+frontend) |
| `.env.example` | monitor/CH 配置样例（cp 为 `.env` 后填写）；应用层默认值见文件尾注 |
| `.gitignore` | 忽略运行时 `data/`、本地 `.env`、打包产物(jar/dist) |
| `init/` | 数据端初始化脚本（clickhouse / kafka / mysql-vos 各一） |
| `data/` | 本地持久化目录（mysql/redis/clickhouse/kafka/backend-logs，运行时生成） |
| `agent/` | VOS 侧 agent 安装包 + 配置样例 |
| `clickhouse/` | ODS 契约 + Kafka 消费 DDL（init 容器挂载为 `/sql`） |
| `monitor/` | 监控页（Dockerfile + 预编译二进制 + 前端源码 + build.sh） |
| `backend/` | `yudao-server/target/yudao-server.jar`(运行物) + `sql/mysql/*.sql`(建库) |
| `frontend/` | `dist/`(vben 静态站) + `nginx.conf`(反代配置) |
| `tools/pull_client.py` | 平台侧多节点拉取客户端 |

## 7. 关于「话单查询 / VOS 管理」定制页
本合并包为**标准 yudao 后台**（登录 / 系统管理），**不含**我们之前在另一仓库 `yk-vos` 里做的「话单查询、VOS 管理页、云客vos 标题、去租户/其他登录方式」等定制。
若测试环境需要这些功能，须先把 `yk-vos`(FastAPI + web-ele) 的定制迁到本仓库，再重新打包。
