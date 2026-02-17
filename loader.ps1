# ==================================
# KMD
# ==================================

$ErrorActionPreference = "Stop"

Write-Host "Downloading BOOTFPS..." -ForegroundColor Cyan

# TLS FIX
[Net.ServicePointManager]::SecurityProtocol =
[Net.SecurityProtocolType]::Tls12

$temp = "$env:TEMP\bootfps"
New-Item -ItemType Directory -Path $temp -Force | Out-Null

try {

Invoke-WebRequest `
"https://truffles3300.github.io/kobmaidai/kobmaidai.ps1" `
-OutFile "$temp\kobmaidai.ps1"

Invoke-WebRequest `
"https://truffles3300.github.io/kobmaidai/kmd.reg" `
-OutFile "$temp\kmd.reg"

Write-Host "Launch Script..." -ForegroundColor Green

Start-Process powershell -ArgumentList @(
"-NoExit",
"-ExecutionPolicy Bypass",
"-File `"$temp\kobmaidai.ps1`""
) -Verb RunAs

}
catch {
Write-Host "ERROR:" -ForegroundColor Red
Write-Host $_
pause
}
