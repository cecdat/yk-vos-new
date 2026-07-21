#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ykvos-agent 的「平台侧拉取客户端」（测试环境用，支持多节点 VOS）。

拓扑（docs/VOS同步Agent规格.md §3.5）：
    VOS 服务器有公网；平台部署测试服务器「没有公网端口」。
    -> 每个 VOS 节点各跑一个 agent，在 VOS 本机起 HTTP 拉取端点(server.listen=":5233")；
    -> 本脚本在平台侧周期 GET 各节点端点，把话单拉回平台落 ClickHouse。

agent 返回的正是 model.Envelope(JSON)，与 Kafka 消息同构。
Envelope 顶层含 vos_id（标识来源节点），落库时一并写入 ODS（多节点去重键 vos_id,flowno）。

多节点：--agent-url 可重复多次，或传 "name=http://host:port"。
    每个节点独立维护游标(next_after)，互不干扰。

两种落库方式(--sink)：
  clickhouse(默认)：把 Envelope.data(列名->值的 JSON 对象) 合并 vos_id 后
                 直接 INSERT 进 vos_cdr_ods(JSONEachRow, 按列名映射, 复用 01_ods_vos.sql 契约)。
                 零依赖，立即跑通。
  kafka         ：把整条 Envelope 发到本机 Kafka topic vos.cdr.live，
                 由 ClickHouse 原生 Kafka 引擎消费(见 clickhouse/test/02_kafka_ingest.sql)，
                 与生产消费链路完全一致(需 kafka-python: pip install kafka-python)。

用法：
  1) 仅验证连通(逐节点拉一批打印到 stderr)：
     python3 pull_client.py --agent-url http://<VOS1公网IP>:5233 \
         --agent-url http://<VOS2公网IP>:5233 --once

  2) 直写 ClickHouse(默认 sink)：
     python3 pull_client.py --agent-url http://<VOS1公网IP>:5233 \
         --agent-url http://<VOS2公网IP>:5233 --clickhouse http://127.0.0.1:8123

  3) 经本机 Kafka 中继(验证生产消费链路)：
     pip install kafka-python
     python3 pull_client.py --agent-url http://<VOS1>:5233 \
         --sink kafka --kafka-bootstrap 127.0.0.1:9092

游标(next_after) 按节点持久化在 --cursor-dir/<node>.cursor，断点续传。

ClickHouse ODS 建表(DDL)：clickhouse/ods/01_ods_vos.sql
Kafka->CH 引擎/MV(DDL)：clickhouse/test/02_kafka_ingest.sql
"""
import argparse
import json
import os
import re
import sys
import time
import urllib.request
import urllib.error

DEFAULT_TABLE = "auto"
DEFAULT_LIMIT = 2000
DEFAULT_CURSOR_DIR = "./state"
POLL_INTERVAL = 5
DEFAULT_CH_TABLE = "vos_cdr_ods"
DEFAULT_KAFKA_BOOTSTRAP = "127.0.0.1:19092"
DEFAULT_KAFKA_TOPIC = "vos.cdr.live"

_SAFE = re.compile(r"[^A-Za-z0-9_\-]")


def parse_nodes(urls):
    """把 --agent-url 列表解析为 [(name, url), ...]。支持 name=url 形式。"""
    nodes = []
    for u in urls:
        if "=" in u:
            name, url = u.split("=", 1)
            nodes.append((name.strip(), url.strip()))
        else:
            # 用 host 作为节点名（文件名安全化）
            host = re.sub(r"^https?://", "", u).split("/")[0]
            nodes.append((_SAFE.sub("_", host), u.strip()))
    return nodes


def discover_tables(agent_url, token):
    """从 agent 获取可同步的话单表清单。如果获取失败，降级使用默认表 e_cdr。"""
    url = "%s/v1/tables" % agent_url.rstrip("/")
    req = urllib.request.Request(url)
    if token:
        req.add_header("Authorization", "Bearer " + token)
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            return data.get("tables", ["e_cdr"])
    except Exception as e:
        print("[pull] 无法获取节点 %s 的同步表清单: %s，降级为 ['e_cdr']" % (agent_url, e), file=sys.stderr)
        return ["e_cdr"]


def fetch_batch(agent_url, token, table, after, limit):
    url = "%s/v1/cdr?table=%s&after=%d&limit=%d" % (
        agent_url.rstrip("/"), table, after, limit)
    req = urllib.request.Request(url)
    if token:
        req.add_header("Authorization", "Bearer " + token)
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


def write_ndjson(fh, rows):
    for r in rows:
        rec = {
            "vos_id": r.get("vos_id"),
            "src_table": r.get("src_table"),
            "flowno": r.get("flowno"),
            "ts": r.get("ts"),
            "payload": json.dumps(r.get("data", {}), ensure_ascii=False),
        }
        fh.write(json.dumps(rec, ensure_ascii=False) + "\n")


def write_clickhouse(ch_url, ch_table, rows):
    # Envelope.data 是 {列名: JSON值} 的对象；合并顶层 vos_id 后，
    # 可直接 JSONEachRow 进 vos_cdr_ods（按列名映射，多节点去重键 vos_id,flowno）。
    lines = []
    for r in rows:
        if not isinstance(r.get("data"), dict):
            continue
        row = dict(r["data"])
        row["vos_id"] = r.get("vos_id")
        lines.append(json.dumps(row, ensure_ascii=False))
    if not lines:
        return 0
    body = ("\n".join(lines) + "\n").encode("utf-8")
    import urllib.parse
    query = "INSERT INTO %s FORMAT JSONEachRow" % ch_table
    url = "%s/?query=%s" % (ch_url.rstrip("/"), urllib.parse.quote(query))
    req = urllib.request.Request(url, data=body, method="POST")
    req.add_header("Content-Type", "text/plain; charset=utf-8")
    with urllib.request.urlopen(req, timeout=30) as resp:
        resp.read()
    return len(lines)


def write_kafka(bootstrap, topic, rows):
    try:
        from kafka import KafkaProducer
    except ImportError:
        print("[pull] 错误：--sink kafka 需要 kafka-python，请先 `pip install kafka-python`",
              file=sys.stderr)
        raise
    prod = KafkaProducer(
        bootstrap_servers=bootstrap,
        value_serializer=lambda v: json.dumps(v, ensure_ascii=False).encode("utf-8"))
    for r in rows:
        prod.send(topic, r)  # r 是整条 Envelope（含 vos_id 顶层字段）
    prod.flush()
    prod.close()
    return len(rows)


def read_cursor(path):
    try:
        with open(path, "r", encoding="utf-8") as f:
            return int(f.read().strip() or "0")
    except (FileNotFoundError, ValueError):
        return 0


def write_cursor(path, value):
    d = os.path.dirname(path)
    if d:
        os.makedirs(d, exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(str(value))


def run_node_once(node_name, agent_url, token, table, limit, cursor_dir, sink,
                 ch_url, ch_table, kafka_bootstrap, kafka_topic, out):
    """拉取单个节点的所有积压数据并落库，返回拉到的总行数。"""
    if table == "auto":
        tables = discover_tables(agent_url, token)
    else:
        tables = [table]

    total_pulled = 0
    for t in tables:
        # 对每张表，循环拉取直至追平
        cursor_file = os.path.join(cursor_dir, "%s_%s.cursor" % (node_name, t))
        while True:
            after = read_cursor(cursor_file)
            try:
                resp = fetch_batch(agent_url, token, t, after, limit)
            except urllib.error.HTTPError as e:
                print("[pull][%s] 表 %s HTTP 错误 %s: %s" % (
                    node_name, t, e.code, e.read().decode("utf-8", "replace")), file=sys.stderr)
                break
            except Exception as e:  # noqa: BLE001
                print("[pull][%s] 表 %s 拉取异常: %s" % (node_name, t, e), file=sys.stderr)
                break

            rows = resp.get("rows", [])
            count = resp.get("count", len(rows))
            next_after = resp.get("next_after", after)
            
            if count == 0:
                break # 本表已追平，切换下一张表

            print("[pull][%s] table=%s after=%d -> count=%d next_after=%d" % (
                node_name, t, after, count, next_after), file=sys.stderr)

            if out:
                with open(out, "a", encoding="utf-8") as fh:
                    write_ndjson(fh, rows)

            if sink == "kafka":
                n = write_kafka(kafka_bootstrap, kafka_topic, rows)
                print("[pull][%s] produced %d Envelopes for %s -> Kafka %s" % (node_name, n, t, kafka_topic),
                      file=sys.stderr)
            else:  # clickhouse (default)
                if not ch_url:
                    print("[pull][%s] 警告：--sink clickhouse 但未给 --clickhouse，仅落盘/跳过" % node_name,
                          file=sys.stderr)
                else:
                    n = write_clickhouse(ch_url, ch_table, rows)
                    print("[pull][%s] wrote %d rows for %s into ClickHouse %s" % (node_name, n, t, ch_table),
                          file=sys.stderr)

            write_cursor(cursor_file, next_after)
            total_pulled += count
            
            # 如果拉取的数量少于单批上限，说明当前表已无更多积压数据，跳出
            if count < limit:
                break

    return total_pulled


def main():
    ap = argparse.ArgumentParser(description="ykvos-agent 平台侧拉取客户端(测试用, 支持多节点)")
    ap.add_argument("--agent-url", action="append", default=[],
                    help="agent HTTP 端点；可重复多次(每个 VOS 节点一个)。支持 name=url 形式。")
    ap.add_argument("--token", default="", help="YK_SERVER_TOKEN(Bearer)，空=不鉴权")
    ap.add_argument("--table", default=DEFAULT_TABLE, help="话单表，默认 auto (自动探索并同步所有历史日表加滚动表)")
    ap.add_argument("--limit", type=int, default=DEFAULT_LIMIT, help="单批行数上限")
    ap.add_argument("--out", default="", help="NDJSON 落盘路径(可选)")
    ap.add_argument("--sink", default="clickhouse", choices=["clickhouse", "kafka"],
                    help="落库方式：clickhouse 直写 ODS(默认) | kafka 本机中继")
    ap.add_argument("--clickhouse", default="", help="ClickHouse HTTP 地址(--sink clickhouse 用)")
    ap.add_argument("--ch-table", default=DEFAULT_CH_TABLE, help="CH 落地表(默认 vos_cdr_ods)")
    ap.add_argument("--kafka-bootstrap", default=DEFAULT_KAFKA_BOOTSTRAP,
                    help="Kafka bootstrap(--sink kafka 用)")
    ap.add_argument("--kafka-topic", default=DEFAULT_KAFKA_TOPIC,
                    help="Kafka topic(默认 vos.cdr.live)")
    ap.add_argument("--cursor-dir", default=DEFAULT_CURSOR_DIR, help="各节点游标目录")
    ap.add_argument("--once", action="store_true", help="只拉一批(每个节点)就退出(验证用)")
    args = ap.parse_args()

    if not args.agent_url:
        ap.error("--agent-url 至少指定一个 VOS 节点")

    nodes = parse_nodes(args.agent_url)
    print("[pull] 节点数=%d: %s" % (len(nodes),
          ", ".join("%s=%s" % (n, u) for n, u in nodes)), file=sys.stderr)

    if args.once:
        for name, url in nodes:
            run_node_once(name, url, args.token, args.table, args.limit, args.cursor_dir,
                          args.sink, args.clickhouse, args.ch_table, args.kafka_bootstrap,
                          args.kafka_topic, args.out)
        return

    print("[pull] 开始持续拉取(每轮遍历所有节点, Ctrl+C 退出)", file=sys.stderr)
    while True:
        for name, url in nodes:
            try:
                run_node_once(name, url, args.token, args.table, args.limit, args.cursor_dir,
                              args.sink, args.clickhouse, args.ch_table, args.kafka_bootstrap,
                              args.kafka_topic, args.out)
            except Exception as e:  # noqa: BLE001
                print("[pull][%s] 未预期异常: %s" % (name, e), file=sys.stderr)
        time.sleep(POLL_INTERVAL)


if __name__ == "__main__":
    main()
