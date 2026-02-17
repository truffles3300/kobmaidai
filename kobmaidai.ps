# =====================================================
# Kobmaidai.com
# ONE COMMAND INSTALL • ALL PC SAFE
# =====================================================

# ---------- AUTO ADMIN ----------
if (!([Security.Principal.WindowsPrincipal]
[Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator"))
{
Start-Process powershell "-WindowStyle Hidden -ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/USER/bootfps-ultra/main/BOOTFPS.ps1 | iex`"" -Verb RunAs
exit
}

$Host.UI.RawUI.WindowTitle = "BOOTFPS ULTRA S+"

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

# ---------- WINDOWS OPT ----------
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f

# ---------- SERVICES ----------
$services = "SysMain","DiagTrack","WSearch"
foreach ($svc in $services){
Set-Service $svc -StartupType Manual -ErrorAction SilentlyContinue
Stop-Service $svc -Force -ErrorAction SilentlyContinue
}

# ---------- GPU CACHE CLEAN ----------
Remove-Item "$env:LOCALAPPDATA\NVIDIA\DXCache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\D3DSCache\*" -Recurse -Force -ErrorAction SilentlyContinue

# =====================================================
# DOWNLOAD + APPLY KMD.REG (AUTO)
# =====================================================

Write-Host "Downloading registry tweak..."

$regurl = "https://raw.githubusercontent.com/USER/bootfps-ultra/main/kmd.reg"
$regfile = "$env:TEMP\kmd.reg"

Invoke-WebRequest $regurl -OutFile $regfile -UseBasicParsing
reg import $regfile

# =====================================================
# CREATE CITIZENFX.INI (AUTO)
# =====================================================

$fivemPath = "$env:LOCALAPPDATA\FiveM\FiveM.app\data"
$iniFile = "$fivemPath\CitizenFX.ini"

if (Test-Path $fivemPath){

@"
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
MinStreamingFileSize=64
MaxStreamingRequests=1024
StreamingRequestBatching=1

[Renderer]
Renderer=DirectX11
MSAA=0
FXAA=0
TextureQuality=0
ShaderQuality=0
ShadowQuality=0
ReflectionQuality=0
AnisotropicFiltering=0
Tessellation=0
PostFX=0
WaterQuality=0
GrassQuality=0
ParticleQuality=0

[Network]
UseNagleAlgorithm=false
"@ | Out-File $iniFile -Encoding ASCII

Write-Host "CitizenFX.ini Applied ✓"
}

# ---------- TEMP CLEAN ----------
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
ipconfig /flushdns

Write-Host ""
Write-Host "ULTRA S+ COMPLETE ✓"
Start-Sleep 3

shutdown /r /t 5