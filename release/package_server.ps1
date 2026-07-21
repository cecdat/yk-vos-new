Param(
    [string]$targetEnv = "dev",
    [string]$version = "1.0.1"
)

$isProd = $targetEnv -eq "prod"
$srcDir = ("dev", "prod")[$isProd]

$app = "ykvos-server-$targetEnv"
$pkg = "$app-$version.tar.gz"
$destPath = "$srcDir/$pkg"

Write-Host "==> Packaging server side ($targetEnv) from $srcDir ..."

Remove-Item -Force $destPath -ErrorAction SilentlyContinue
Remove-Item -Force $pkg -ErrorAction SilentlyContinue

tar.exe -czf $pkg -C $srcDir .

Move-Item -Path $pkg -Destination $destPath -Force

Write-Host "==> Server package built successfully at: $destPath"
