# ==================================
# BOOTFPS ULTRA S+ UNIVERSAL LOADER
# ==================================

$ErrorActionPreference = "SilentlyContinue"

# TLS FIX (กันโหลดไม่ได้บางเครื่อง)
[Net.ServicePointManager]::SecurityProtocol =
[Net.SecurityProtocolType]::Tls12

# Temp folder
$temp = "$env:TEMP\bootfps"
New-Item -ItemType Directory -Path $temp -Force | Out-Null

# Download files from GitHub Pages
Invoke-WebRequest "https://truffles3300.github.io/kobmaidai/kobmaidai.ps1" -OutFile "$temp\kobmaidai.ps1"
Invoke-WebRequest "https://truffles3300.github.io/kobmaidai/kmd.reg" -OutFile "$temp\kmd.reg"

# Run main script as ADMIN
Start-Process powershell `
"-ExecutionPolicy Bypass -File `"$temp\kobmaidai.ps1`"" `
-Verb RunAs
