$ErrorActionPreference = "Stop"

# ===============================
# AUTO ADMIN (IRM SAFE VERSION)
# ===============================

$currentUser = New-Object Security.Principal.WindowsPrincipal `
    ([Security.Principal.WindowsIdentity]::GetCurrent())

$IsAdmin = $currentUser.IsInRole(
    [Security.Principal.WindowsBuiltinRole]::Administrator
)

# ถ้าไม่ได้เปิดแบบ Admin → เปิดใหม่
if (-not $IsAdmin) {

    Start-Process powershell `
        -ArgumentList "-ExecutionPolicy Bypass -NoProfile -Command `"irm https://truffles3300.github.io/kobmaidai/kobmaidai.ps1 | iex`"" `
        -Verb RunAs

    exit
}

function Pause-End {
    Write-Host ""
    Write-Host "Press ENTER to continue..." -ForegroundColor Yellow
    Read-Host | Out-Null
}

# =====================================================
# MENU LOOP (กันหน้าต่างหาย)
# =====================================================

while ($true) {

try {

Clear-Host
$Host.UI.RawUI.WindowTitle = "BOOTFPS ULTRA S+"

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "            Kobmaidai.com            "
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1 - APPLY ULTRA FPS (RECOMMENDED)" -ForegroundColor Green
Write-Host "2 - RESTORE WINDOWS DEFAULT" -ForegroundColor Yellow
Write-Host "0 - EXIT"
Write-Host ""

$choice = Read-Host "Select Option"

# =====================================================
# EXIT
# =====================================================

if ($choice -eq "0") { break }

# =====================================================
# RESTORE MODE
# =====================================================

if ($choice -eq "2") {

Write-Host "RESTORING WINDOWS DEFAULT..." -ForegroundColor Yellow

powercfg -setactive SCHEME_BALANCED
powercfg -restoredefaultschemes

bcdedit /deletevalue disabledynamictick 2>$null
bcdedit /deletevalue useplatformtick 2>$null
bcdedit /deletevalue tscsyncpolicy 2>$null

reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 1 /f
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 6 /f
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 10 /f

reg delete "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" `
/v Win32PrioritySeparation /f 2>$null

reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
/v NetworkThrottlingIndex /f 2>$null

reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
/v SystemResponsiveness /f 2>$null

cmd /c "sc config DiagTrack start= auto" 2>$null
cmd /c "sc start DiagTrack" 2>$null

$DefaultServices = "SysMain","WSearch","DiagTrack"
foreach ($svc in $DefaultServices){
    Set-Service $svc -StartupType Automatic -ErrorAction SilentlyContinue
    Start-Service $svc -ErrorAction SilentlyContinue
}

Write-Host "RESTORE COMPLETE ✓" -ForegroundColor Green
Pause-End
continue
}


# =====================================================
# APPLY MODE
# =====================================================

if ($choice -ne "1") { continue }

Clear-Host
Write-Host "BOOTFPS ULTRA S+ STARTING..." -ForegroundColor Cyan
Start-Sleep 2

# ---------- Restore Point ----------
Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
Checkpoint-Computer -Description "BOOTFPS_SPLUS" -RestorePointType MODIFY_SETTINGS

# ---------- Power ----------
powercfg -setactive SCHEME_MIN
powercfg -change standby-timeout-ac 0
powercfg -change monitor-timeout-ac 0

# ---------- Mouse ----------
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f

# ---------- CPU ----------
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" `
/v Win32PrioritySeparation /t REG_DWORD /d 38 /f

# ---------- Gaming ----------
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
/v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
/v SystemResponsiveness /t REG_DWORD /d 0 /f

# ---------- Timer ----------
bcdedit /set disabledynamictick yes
bcdedit /set useplatformtick yes
bcdedit /set tscsyncpolicy Enhanced

# ---------- Services ----------
$services = "SysMain","DiagTrack","WSearch"
foreach ($svc in $services){
    Set-Service $svc -StartupType Manual -ErrorAction SilentlyContinue
    Stop-Service $svc -Force -ErrorAction SilentlyContinue
}

# ---------- GPU Cache ----------
Remove-Item "$env:LOCALAPPDATA\NVIDIA\DXCache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\D3DSCache\*" -Recurse -Force -ErrorAction SilentlyContinue

# =====================================================
# FIVEM ENGINE
# =====================================================

Write-Host "Applying FiveM ULTRA Config..."

$FiveMData = "$env:LOCALAPPDATA\FiveM\FiveM.app\data"
$CitizenFile = "$FiveMData\CitizenFX.ini"

New-Item -ItemType Directory -Path $FiveMData -Force | Out-Null

@"
[Game]
GraphicsQuality=0
TextureQuality=0
ShadowQuality=0
ReflectionQuality=0
PopulationDensity=0.0
DistanceScaling=0.3
VSync=false
FrameLimit=0

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

# ---------- Cache Clean ----------
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

# =====================================================
# ULTRA UI TWEAKS
# =====================================================

Write-Host "Applying UltraUI Tweaks..." -ForegroundColor Cyan

# Disable Activity History
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v PublishUserActivities /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v UploadUserActivities /t REG_DWORD /d 0 /f

# Disable Consumer Features
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f

# Disable Explorer Auto Folder Discovery
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" /v FolderType /t REG_SZ /d NotSpecified /f

# Disable Location Tracking
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v DisableLocation /t REG_DWORD /d 1 /f

# Disable Telemetry
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
sc stop DiagTrack 2>$null
sc config DiagTrack start= disabled

# Disable PowerShell Telemetry
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell" /v EnableScriptBlockLogging /t REG_DWORD /d 0 /f

# Disable WPBT
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v DisableWpbtExecution /t REG_DWORD /d 1 /f

# Enable End Task Right Click
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" /v TaskbarEndTask /t REG_DWORD /d 1 /f

# Remove Widgets
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f

# Set services manual (extra safety)
$UltraServices = "SysMain","WSearch","DiagTrack"
foreach ($svc in $UltraServices){
    Set-Service $svc -StartupType Manual -ErrorAction SilentlyContinue
}

# Disk cleanup
cleanmgr /verylowdisk

Write-Host "RESTORE COMPLETE ✓" -ForegroundColor Green
Pause-End
continue
}

ipconfig /flushdns

Write-Host ""
Write-Host "ULTRA S+ COMPLETE ✓" -ForegroundColor Green
Write-Host "Restarting in 5 seconds..."

Start-Sleep 5
shutdown /r /t 0

}
catch {
    Write-Host ""
    Write-Host "===== ERROR OCCURRED =====" -ForegroundColor Red
    Write-Host $_
    Pause-End
}

}



