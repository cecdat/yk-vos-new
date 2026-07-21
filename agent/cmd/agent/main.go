// Command ykvos-agent 是部署在 VOS 服务器本机的话单同步 agent。
// 详见 docs/VOS同步Agent规格.md。
//
// 所有业务参数均在 config.yaml 中配置，运行时不接收命令行参数（内网单配置部署）。
// 仅保留两个非业务开关：
//   -config  可选，指向配置文件；缺省按 /opt/ykvos-agent/etc/config.yaml → ./config.yaml 顺序查找
//   -version  打印版本并退出
package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"path/filepath"
	"sync"
	"syscall"
	"time"

	"github.com/yk-vos/ykvos-agent/internal/commander"
	"github.com/yk-vos/ykvos-agent/internal/config"
	"github.com/yk-vos/ykvos-agent/internal/logx"
	"github.com/yk-vos/ykvos-agent/internal/puller"
	"github.com/yk-vos/ykvos-agent/internal/scanner"
	"github.com/yk-vos/ykvos-agent/internal/server"
	"github.com/yk-vos/ykvos-agent/internal/sink"
	"github.com/yk-vos/ykvos-agent/internal/source"
	"github.com/yk-vos/ykvos-agent/internal/state"
	"github.com/yk-vos/ykvos-agent/internal/status"
	"github.com/yk-vos/ykvos-agent/internal/telemetry"
)

// version 由编译期 -ldflags "-X main.version=..." 注入。
var version = "dev"

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, "fatal:", err)
		os.Exit(1)
	}
}

// resolveConfigPath 解析 -config：显式给定则直接用；
// 否则按固定顺序查找默认路径，使服务可零参数启动。
func resolveConfigPath(p string) string {
	if p != "" {
		return p
	}
	candidates := []string{
		"/opt/ykvos-agent/etc/config.yaml",
		filepath.Join(".", "config.yaml"),
	}
	for _, c := range candidates {
		if _, err := os.Stat(c); err == nil {
			return c
		}
	}
	return candidates[0] // 让 config.Load 报「文件不存在」更友好
}

func run() error {
	configPath  := flag.String("config", "", "配置文件路径（可选；默认 /opt/ykvos-agent/etc/config.yaml，其次 ./config.yaml）")
	showVersion := flag.Bool("version", false, "打印版本并退出")
	flag.Parse()

	if *showVersion {
		fmt.Println("ykvos-agent", version)
		return nil
	}

	resolved := resolveConfigPath(*configPath)
	cfg, err := config.Load(resolved)
	if err != nil {
		return err
	}

	logx.Init(cfg.Log.Level, cfg.Log.Path)
	log := logx.Module("main")
	log.Info("ykvos-agent 启动", "version", version, "config", resolved)

	log.Info("配置加载完成",
		"instance", cfg.Instance.ID,
		"mysql", fmt.Sprintf("%s:%d/%s", cfg.MySQL.Host, cfg.MySQL.Port, cfg.MySQL.Database),
		"kafka_topic", cfg.Kafka.CdrTopic,
	)

	statePath := cfg.State.File
	st, err := state.Load(statePath)
	if err != nil {
		return err
	}

	// ── 信号驱动的优雅退出：收到 SIGTERM/SIGINT 后取消 ctx ──
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGTERM, syscall.SIGINT)
	defer stop()

	src, err := source.Open(cfg.MySQL)
	if err != nil {
		return err
	}
	defer src.Close()
	log.Info("VOS MySQL 只读源已连接")

	// ── 同步状态注册表（§监控 / A5）：各表 worker 每轮刷新，供 /v1/status 暴露 ──
	reg := status.New()

	// ── 入站拉取端点（§3.5 双向 / 测试环境）：listen 非空即起 HTTP 服务，
	//    由平台主动来拉；与 Kafka 推送可并存（真·双向）。listen 空则不起任何 inbound 端口。──
	var httpSrv *server.Server
	if cfg.Server.Listen != "" {
		httpSrv = server.New(src, cfg.Instance.ID, cfg.Server.Token, cfg.Tables, reg)
		go func() {
			if e := httpSrv.Start(ctx, cfg.Server.Listen, cfg.Server.ReadTimeoutSeconds); e != nil {
				log.Error("HTTP 拉取端点异常退出", "err", e.Error())
			}
		}()
	} else {
		log.Info("server.listen 未配置，不起入站端点（延续 §9 无 inbound 基线）")
	}

	// ── Kafka 推送：仅 sync.mode=kafka 时启用；off 时跳过（适配测试环境 Kafka 不可达）──
	var wg sync.WaitGroup
	if cfg.Sync.Mode == "kafka" {
		cdrSink, err := sink.NewKafka(cfg.Kafka, cfg.Kafka.CdrTopic)
		if err != nil {
			return err
		}
		defer cdrSink.Close()

		// ── 受控历史回填 / 遥测 / 指令分发器（先建好，门闸后再启动 puller）──
		agentScanner := scanner.NewScanner(cfg.Instance.ID, src.DB(), st, cdrSink)
		backfillWorker := puller.NewBackfillWorker(cfg.Instance.ID, src, src.DB(), st, cdrSink, cfg.Sync.BatchSize)
		telemetryMgr := telemetry.NewTelemetryManager(cfg.Instance.ID, src.DB(), cdrSink)
		// 启动门闸信号：服务端下发 start 指令后由 commander 关闭，main 才启动 puller。
		startCh := make(chan struct{})
		cmdMgr := commander.NewCommander(cfg.Instance.ID, src.DB(), cfg.Kafka, cdrSink, backfillWorker, agentScanner, startCh)

		// ── 先启动指令监听与周期心跳：即便 puller 未起，也能收指令、能上报 ──
		wg.Add(1)
		go func() {
			defer wg.Done()
			cmdMgr.Start(ctx)
		}()
		wg.Add(1)
		go func() {
			defer wg.Done()
			telemetryMgr.Start(ctx)
		}()

		// ── 启动门闸：未连上服务端（控制面 Kafka 不可达）前，puller 不启动，
		//    处于「等待连接」状态，避免在无服务端消费时盲目推送话单 ──
		// ── 启动门闸：后端未添加并授权该 VOS 节点前（即未下发 start 指令），
		//    puller 不启动，避免无授权盲目推送话单 ──
		log.Info("已启动心跳上报，等待服务端下发 start 指令（需在后端添加并授权该 VOS 节点）…")
		select {
		case <-ctx.Done():
			return nil
		case <-startCh:
			log.Info("收到服务端 start 指令，开始数据同步")
		}

		// ── 门闸通过后才起 puller：按 config.tables 逐表 worker；cdr 自动发现滚动日表 ──
		for _, t := range cfg.Tables {
			switch t.Type {
			case "cdr":
				names := []string{t.Name}
				if t.Name == source.RollingCDRTable {
					// 默认仅自动同步实时表 e_cdr 和当天日表 e_cdr_YYYYMMDD（如果存在）
					names = []string{source.RollingCDRTable}
					if discovered, derr := src.CDRTables(ctx); derr == nil {
						todayTable := fmt.Sprintf("e_cdr_%s", time.Now().Format("20060102"))
						for _, dName := range discovered {
							if dName == todayTable {
								names = append(names, dName)
								break
							}
						}
					} else {
						log.Error("发现 CDR 日表失败，仅同步滚动表", "err", derr.Error())
					}
				}
				for _, n := range names {
					tn := n
					p := puller.New(src, cdrSink, st, cfg.Sync, cfg.Instance.ID, tn, reg)
					wg.Add(1)
					go func() {
						defer wg.Done()
						p.Run(ctx)
					}()
				}
			case "dimension":
				dp := puller.NewDimension(src, cdrSink, st, t, cfg.Instance.ID, reg)
				wg.Add(1)
				go func() {
					defer wg.Done()
					dp.Run(ctx)
				}()
			}
		}

		// 启动后延迟 2 秒自动进行一次可用日表扫描上报
		go func() {
			select {
			case <-ctx.Done():
				return
			case <-time.After(2 * time.Second):
				if err := agentScanner.ScanAndReport(context.Background()); err != nil {
					log.Error("启动时可用历史表扫描上报失败", "err", err.Error())
				}
			}
		}()
	} else {
		log.Info("sync.mode=off，跳过 Kafka 推送（仅保留 serve 端点，适配测试环境）")
	}

	<-ctx.Done()
	log.Info("开始优雅退出，等待订阅者收尾并落盘水位")
	wg.Wait()
	if err := st.Flush(); err != nil {
		log.Error("退出时水位落盘失败", "err", err.Error())
	}
	// httpSrv.Start 内部已监听 ctx.Done 做 HTTP 优雅关闭
	log.Info("ykvos-agent 已退出")
	return nil
}
