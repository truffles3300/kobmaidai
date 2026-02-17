$ErrorActionPreference = "Stop"

try {

# =====================================================
# AUTO ADMIN
# =====================================================

$IsAdmin = ([Security.Principal.WindowsPrincipal]
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

if (-not $IsAdmin) {
    Start-Process powershell.exe `
        -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    exit
}

$Host.UI.RawUI.WindowTitle = "BOOTFPS ULTRA S+"
Clear-Host

# =====================================================
# MENU
# =====================================================

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "            Kobmaidai.com            "
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1 - APPLY ULTRA FPS (RECOMMENDED)" -ForegroundColor Green
Write-Host "2 - RESTORE WINDOWS DEFAULT" -ForegroundColor Yellow
Write-Host ""

$choice = Read-Host "Select Option"

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

sc config DiagTrack start= auto 2>$null
sc start DiagTrack 2>$null

$DefaultServices = "SysMain","WSearch","DiagTrack"
foreach ($svc in $DefaultServices){
Set-Service $svc -StartupType Automatic -ErrorAction SilentlyContinue
Start-Service $svc -ErrorAction SilentlyContinue
}

Write-Host "RESTORE COMPLETE ✓" -ForegroundColor Green
shutdown /r /t 5
exit
}

if ($choice -ne "1") {
Write-Host "Invalid Option"
pause
exit
}

# =====================================================
# APPLY MODE
# =====================================================

Clear-Host
Write-Host "BOOTFPS ULTRA S+ STARTING..." -ForegroundColor Cyan
Start-Sleep 2

# ---------- Restore Point ----------
Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
Checkpoint-Computer -Description "BOOTFPS_SPLUS" -RestorePointType MODIFY_SETTINGS

# ---------- Power Plan ----------
powercfg -setactive SCHEME_MIN
powercfg -change standby-timeout-ac 0
powercfg -change monitor-timeout-ac 0

# ---------- Mouse Input ----------
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f

# ---------- CPU Priority ----------
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" `
/v Win32PrioritySeparation /t REG_DWORD /d 38 /f

# ---------- Gaming Scheduler ----------
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
# FIVE M ENGINE
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

ipconfig /flushdns

Write-Host ""
Write-Host "ULTRA S+ COMPLETE ✓" -ForegroundColor Green
shutdown /r /t 5

}
catch {
Write-Host ""
Write-Host "===== ERROR OCCURRED =====" -ForegroundColor Red
Write-Host $_
pause
}
