# yk-vos-monitor —— 极简数据链路监控页
# 静态二进制（CGO_ENABLED=0 交叉编译），FROM scratch 运行，无需任何基础镜像拉取。
# 构建上下文为 monitor/ 目录；预编译二进制位于 dist/monitor（已随仓库提交）。
FROM docker.1ms.run/alpine:latest
COPY dist/monitor /monitor
RUN chmod +x /monitor
EXPOSE 8088
ENTRYPOINT ["/monitor"]
