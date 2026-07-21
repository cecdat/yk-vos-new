Param(
    [string]$version = "1.0.0",
    [string]$targetEnv = "dev" # dev (测试) 或 prod (正式)
)

$app = "ykvos-agent"
$pkg = "ykvos-agent"      # 解压后的根目录为 ykvos-agent
$tarName = "$app-$version.tar.gz"
$dist = "dist"

# 1) Clean and recreate output dirs
if (Test-Path "$dist") { Remove-Item -Recurse -Force "$dist" }
New-Item -ItemType Directory -Path "$dist/$pkg/agent/bin" | Out-Null
New-Item -ItemType Directory -Path "$dist/$pkg/agent/etc" | Out-Null

# 2) Compile directly to the final layout path
Write-Host "==> Compiling Go binary for Linux..."
$env:CGO_ENABLED="0"
$env:GOOS="linux"
$env:GOARCH="amd64"
go build -ldflags="-s -w -X main.version=$version" -o "$dist/$pkg/agent/bin/$app" ./cmd/agent

# 3) Copy configurations and deploy scripts
Write-Host "==> Copying configurations and deploy scripts..."
Copy-Item "config.example.yaml" -Destination "$dist/$pkg/agent/etc/config.yaml"

Copy-Item "deploy/install.sh" -Destination "$dist/$pkg/install.sh"
Copy-Item "deploy/uninstall.sh" -Destination "$dist/$pkg/uninstall.sh"
Copy-Item "deploy/readme.txt" -Destination "$dist/$pkg/readme.txt"
Copy-Item "deploy/.env.example" -Destination "$dist/$pkg/.env.example"
Copy-Item "deploy/ykvos-agent.initd" -Destination "$dist/$pkg/$app.initd"
Copy-Item "deploy/ykvos-monitor.initd" -Destination "$dist/$pkg/${app}-monitor.initd"
Copy-Item "deploy/ykvos-agent.service" -Destination "$dist/$pkg/$app.service"

# 4) Archive using native tar.exe
Write-Host "==> Creating tarball..."
tar.exe -czf "$dist/$tarName" -C "$dist" "$pkg"

# 5) Copy to corresponding release directory (clean old versions first to avoid bundling history)
$releaseDest = "../release/$targetEnv/agent"
if (!(Test-Path $releaseDest)) { New-Item -ItemType Directory -Path $releaseDest | Out-Null }
Get-ChildItem "$releaseDest/ykvos-agent-*.tar.gz" -ErrorAction SilentlyContinue | Remove-Item -Force
Copy-Item -Force "$dist/$tarName" -Destination "$releaseDest/$tarName"

Write-Host "==> Package successfully created and output to: $releaseDest/$tarName"
