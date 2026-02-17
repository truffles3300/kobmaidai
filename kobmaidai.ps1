$ErrorActionPreference = "Stop"

try {

# =====================================================
# KMD
# =====================================================

# ---------- AUTO ADMIN ----------
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

if (-not $IsAdmin) {
    Start-Process powershell.exe `
        -ArgumentList "-NoExit -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    exit
}

$Host.UI.RawUI.WindowTitle = "BOOTFPS ULTRA S+"
Clear-Host

# ---------- UI MENU ----------
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "        BOOTFPS ULTRA S+"
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1 - APPLY ULTRA FPS (RECOMMENDED)" -ForegroundColor Green
Write-Host "2 - RESTORE WINDOWS DEFAULT" -ForegroundColor Yellow
Write-Host ""

$choice = Read-Host "Select Option"

if ($choice -eq "2") {

    Write-Host "Restoring Defaults..."

    powercfg -setactive SCHEME_BALANCED
    bcdedit /deletevalue disabledynamictick
    bcdedit /deletevalue useplatformtick
    bcdedit /deletevalue tscsyncpolicy

    Write-Host "Restore Complete ✓"
    pause
    exit
}

if ($choice -ne "1") {
    Write-Host "Invalid Option"
    pause
    exit
}

Clear-Host
Write-Host "BOOTFPS ULTRA S+ STARTING..." -ForegroundColor Cyan
Start-Sleep 2

# ---------- RESTORE POINT ----------
Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
Checkpoint-Computer -Description "BOOTFPS_SPLUS" -RestorePointType MODIFY_SETTINGS

# ---------- POWER PLAN ----------
powercfg -setactive SCHEME_MIN
powercfg -change standby-timeout-ac 0
powercfg -change monitor-timeout-ac 0

# ---------- INPUT LAG ----------
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f

# ---------- CPU PRIORITY ----------
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" `
/v Win32PrioritySeparation /t REG_DWORD /d 38 /f

# ---------- GAMING SCHEDULER ----------
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
/v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
/v SystemResponsiveness /t REG_DWORD /d 0 /f

# ---------- TIMER ----------
bcdedit /set disabledynamictick yes
bcdedit /set useplatformtick yes
bcdedit /set tscsyncpolicy Enhanced

# ---------- SERVICES ----------
$services = "SysMain","DiagTrack","WSearch"
foreach ($svc in $services){
Set-Service $svc -StartupType Manual -ErrorAction SilentlyContinue
Stop-Service $svc -Force -ErrorAction SilentlyContinue
}

# ---------- GPU CACHE ----------
Remove-Item "$env:LOCALAPPDATA\NVIDIA\DXCache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\D3DSCache\*" -Recurse -Force -ErrorAction SilentlyContinue

# ---------- IMPORT REG ----------
$regPath = Join-Path $PSScriptRoot "kmd.reg"
if (Test-Path $regPath) {
Write-Host "Applying kmd.reg..."
reg import $regPath
}

Write-Host "Applying UltraUI Tweaks..." -ForegroundColor Cyan

# ---------- ULTRA UI ----------
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v PublishUserActivities /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v UploadUserActivities /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f

sc stop DiagTrack 2>$null
sc config DiagTrack start= disabled

cleanmgr /verylowdisk

Write-Host "Applying UltraUI Tweaks..." -ForegroundColor Cyan

# ---------- Disable Activity History ----------
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v PublishUserActivities /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v UploadUserActivities /t REG_DWORD /d 0 /f

# ---------- Disable Consumer Features ----------
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
/v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f

# ---------- Disable Explorer Automatic Folder Discovery ----------
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" `
/v FolderType /t REG_SZ /d NotSpecified /f

# ---------- Disable Location Tracking ----------
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" `
/v DisableLocation /t REG_DWORD /d 1 /f

# ---------- Disable Telemetry ----------
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
/v AllowTelemetry /t REG_DWORD /d 0 /f

sc stop DiagTrack 2>$null
sc config DiagTrack start= disabled

# ---------- Disable PowerShell Telemetry ----------
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell" `
/v EnableScriptBlockLogging /t REG_DWORD /d 0 /f

# ---------- Disable Windows Platform Binary Table ----------
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" `
/v DisableWpbtExecution /t REG_DWORD /d 1 /f

# ---------- Enable End Task With Right Click ----------
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" `
/v TaskbarEndTask /t REG_DWORD /d 1 /f

# ---------- Remove Widgets ----------
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
/v TaskbarDa /t REG_DWORD /d 0 /f

# ---------- Set Services To Manual ----------
$UltraServices = "SysMain","WSearch","DiagTrack"
foreach ($svc in $UltraServices){
Set-Service $svc -StartupType Manual -ErrorAction SilentlyContinue
}

# ---------- Run Disk Cleanup ----------
cleanmgr /verylowdisk

# =====================================================
# FIVE M ULTRA ENGINE AUTO
# =====================================================

Write-Host "Applying FiveM ULTRA Config..."

$FiveMData = "$env:LOCALAPPDATA\FiveM\FiveM.app\data"
$CitizenFile = "$FiveMData\CitizenFX.ini"

New-Item -ItemType Directory -Path $FiveMData -Force | Out-Null

$CitizenINI = @"
[Game]
UpdateChannel=production
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
EnableDispatchAudio=0
DisableShaderPrecache=1

[Streaming]
UseResourceCache=1
CacheSize=14000
MaxStreamingRequests=1024

[Renderer]
Renderer=DirectX11
MSAA=0
FXAA=0
ShaderQuality=0
PostFX=0
GrassQuality=0

[Network]
UseNagleAlgorithm=false
"@

Set-Content -Path $CitizenFile -Value $CitizenINI -Encoding ASCII

Write-Host "CitizenFX.ini Applied ✓"

# ---------- CACHE CLEAN ----------
$cachePaths = @(
"$env:LOCALAPPDATA\FiveM\FiveM.app\data\cache",
"$env:LOCALAPPDATA\FiveM\FiveM.app\data\server-cache",
"$env:LOCALAPPDATA\FiveM\FiveM.app\data\server-cache-priv"
)

foreach ($path in $cachePaths){
Remove-Item "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
}

Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

ipconfig /flushdns

Write-Host ""
Write-Host "ULTRA S+ COMPLETE ✓" -ForegroundColor Green
Write-Host "Restarting PC..."

Start-Sleep 5
shutdown /r /t 5

}
catch {
Write-Host ""
Write-Host "===== ERROR OCCURRED =====" -ForegroundColor Red
Write-Host $_
Write-Host ""
pause
}

