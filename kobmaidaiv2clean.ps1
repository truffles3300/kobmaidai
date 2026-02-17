$ErrorActionPreference = "Continue"

# =====================================================
# AUTO ADMIN
# =====================================================

$currentUser = New-Object Security.Principal.WindowsPrincipal `
([Security.Principal.WindowsIdentity]::GetCurrent())

if (-not $currentUser.IsInRole(
[Security.Principal.WindowsBuiltinRole]::Administrator)) {

Start-Process powershell `
-ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
-Verb RunAs
exit
}

# =====================================================
# UI
# =====================================================

$Host.UI.RawUI.WindowTitle = "KOBMAIDAI ULTRA PERFORMANCE TOOL V2"

function Pause-End {
Write-Host ""
Read-Host "Press ENTER to continue" | Out-Null
}

# =====================================================
# DOWNLOAD REG
# =====================================================

$temp = "$env:TEMP\kobmaidai"
New-Item $temp -ItemType Directory -Force | Out-Null

Invoke-WebRequest `
"https://truffles3300.github.io/kobmaidai/kmd.reg" `
-OutFile "$temp\kmd.reg" -UseBasicParsing

# =====================================================
# SAFE SERVICES LIST
# =====================================================

$SafeServices = @(
"SysMain","WSearch","DiagTrack","MapsBroker",
"Fax","XblGameSave","XboxGipSvc","XboxNetApiSvc",
"PrintNotify","RemoteRegistry","WerSvc",
"RetailDemo","WalletService","WMPNetworkSvc"
)

# =====================================================
# MENU LOOP
# =====================================================

while ($true) {

Clear-Host
Write-Host "===================================" -ForegroundColor Cyan
Write-Host "        KOBMAIDAI V2 CLEAN         "
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1 - APPLY ULTRA PERFORMANCE" -ForegroundColor Green
Write-Host "2 - RESTORE WINDOWS DEFAULT"
Write-Host "0 - EXIT"
Write-Host ""

$choice = Read-Host "Select Option"

if ($choice -eq "0"){ break }

# =====================================================
# RESTORE MODE
# =====================================================

if ($choice -eq "2"){

Write-Host "Restoring Windows..." -ForegroundColor Yellow

powercfg -restoredefaultschemes

bcdedit /deletevalue disabledynamictick 2>$null
bcdedit /deletevalue useplatformtick 2>$null
bcdedit /deletevalue tscsyncpolicy 2>$null

$SafeServices | ForEach-Object {
Set-Service $_ -StartupType Automatic -ErrorAction SilentlyContinue
Start-Service $_ -ErrorAction SilentlyContinue
}

reg delete "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" `
/v Win32PrioritySeparation /f 2>$null

Write-Host "RESTORE COMPLETE ✓" -ForegroundColor Green
Pause-End
continue
}

# =====================================================
# APPLY MODE
# =====================================================

if ($choice -ne "1"){ continue }

Clear-Host
Write-Host "Starting ULTRA Optimization..." -ForegroundColor Cyan
Start-Sleep 2

# ---------- Restore Point ----------
Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
Checkpoint-Computer -Description "KMD_BEFORE_TWEAK" `
-RestorePointType MODIFY_SETTINGS

# ---------- POWER ----------
powercfg -setactive SCHEME_MIN

# ---------- CPU Scheduler ----------
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" `
/v Win32PrioritySeparation /t REG_DWORD /d 38 /f

# ---------- Gaming ----------
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
/v SystemResponsiveness /t REG_DWORD /d 0 /f

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
/v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f

# ---------- Telemetry ----------
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
/v AllowTelemetry /t REG_DWORD /d 0 /f

# ---------- TIMER ----------
bcdedit /set disabledynamictick yes
bcdedit /set useplatformtick yes
bcdedit /set tscsyncpolicy Enhanced

# ---------- SERVICES ----------
Write-Host "Optimizing Services..."

foreach ($svc in $SafeServices){
Set-Service $svc -StartupType Manual -ErrorAction SilentlyContinue
Stop-Service $svc -Force -ErrorAction SilentlyContinue
}

# ---------- IMPORT REG ----------
Write-Host "Importing KMD Registry..."
Start-Process regedit.exe `
-ArgumentList "/s `"$temp\kmd.reg`"" `
-Wait

# =====================================================
# FIVEM ULTRA ENGINE
# =====================================================

Write-Host "Applying FiveM Config..."

$FiveMData="$env:LOCALAPPDATA\FiveM\FiveM.app\data"
$CitizenFile="$FiveMData\CitizenFX.ini"

New-Item -ItemType Directory -Path $FiveMData -Force | Out-Null

@"
[Game]
GraphicsQuality=0
TextureQuality=0
ShadowQuality=0
ReflectionQuality=0
PopulationDensity=0.0
PopulationVariety=0.0
DistanceScaling=0.3
ExtendedDistanceScaling=0.3
VSync=false
FrameLimit=0
DisableNvApi=1
NvThreadedOptimization=1

[Streaming]
UseResourceCache=1
CacheSize=14000

[Renderer]
Renderer=DirectX11
MSAA=0
FXAA=0
ShaderQuality=0

[Network]
UseNagleAlgorithm=false
"@ | Set-Content $CitizenFile -Encoding ASCII

# ---------- CACHE CLEAN ----------
$cachePaths=@(
"$env:LOCALAPPDATA\FiveM\FiveM.app\data\cache",
"$env:LOCALAPPDATA\FiveM\FiveM.app\data\server-cache",
"$env:LOCALAPPDATA\FiveM\FiveM.app\data\server-cache-priv"
)

foreach($path in $cachePaths){
Remove-Item "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
}

# ---------- GPU CACHE ----------
Remove-Item "$env:LOCALAPPDATA\NVIDIA\DXCache\*" `
-Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\D3DSCache\*" `
-Recurse -Force -ErrorAction SilentlyContinue

# ---------- CLEAN ----------
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

cleanmgr /verylowdisk
ipconfig /flushdns

# =====================================================
# FINISH
# =====================================================

Write-Host ""
Write-Host "ULTRA PERFORMANCE APPLIED ✓" -ForegroundColor Green
Write-Host "Restarting..."

Start-Sleep 5
shutdown /r /t 0
}
