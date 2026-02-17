$ErrorActionPreference = "Continue"

# ===============================
# AUTO ADMIN (IRM SAFE VERSION)
# ===============================

$currentUser = New-Object Security.Principal.WindowsPrincipal `
([Security.Principal.WindowsIdentity]::GetCurrent())

$IsAdmin = $currentUser.IsInRole(
[Security.Principal.WindowsBuiltinRole]::Administrator)

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

# ===============================
# DOWNLOAD REG AUTO
# ===============================

$temp = "$env:TEMP\kobmaidai"
New-Item $temp -ItemType Directory -Force | Out-Null

Invoke-WebRequest `
"https://truffles3300.github.io/kobmaidai/kmd.reg" `
-OutFile "$temp\kmd.reg" -UseBasicParsing


# =====================================================
# MENU LOOP
# =====================================================

while ($true) {

try {

Clear-Host
$Host.UI.RawUI.WindowTitle = "BOOTFPS ULTRA S+"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "            Kobmaidai.com            "
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1 - APPLY ULTRA FPS (RECOMMENDED)" -ForegroundColor Green
Write-Host "2 - RESTORE WINDOWS DEFAULT" -ForegroundColor Yellow
Write-Host "0 - EXIT"
Write-Host ""

$choice = Read-Host "Select Option"

if ($choice -eq "0") { break }

# =====================================================
# RESTORE MODE
# =====================================================

if ($choice -eq "2") {

Write-Host "RESTORING WINDOWS DEFAULT..." -ForegroundColor Yellow

powercfg -restoredefaultschemes

bcdedit /deletevalue disabledynamictick 2>$null
bcdedit /deletevalue useplatformtick 2>$null
bcdedit /deletevalue tscsyncpolicy 2>$null

cmd /c "sc config DiagTrack start= auto"
cmd /c "sc start DiagTrack"

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

# ---------- POWER ----------
powercfg -setactive SCHEME_MIN

# ---------- CPU ----------
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" `
/v Win32PrioritySeparation /t REG_DWORD /d 38 /f

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

# =====================================================
# IMPORT KMD.REG
# =====================================================

Write-Host "Importing KMD Registry..." -ForegroundColor Cyan

Start-Process regedit.exe `
-ArgumentList "/s `"$temp\kmd.reg`"" `
-Wait


# =====================================================
# FIVEM ENGINE CONFIG (เพิ่มให้)
# =====================================================

Write-Host "Applying FiveM ULTRA Config..." -ForegroundColor Cyan

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


# ---------- FiveM Cache Clean ----------
$cachePaths = @(
"$env:LOCALAPPDATA\FiveM\FiveM.app\data\cache",
"$env:LOCALAPPDATA\FiveM\FiveM.app\data\server-cache",
"$env:LOCALAPPDATA\FiveM\FiveM.app\data\server-cache-priv"
)

foreach ($path in $cachePaths){
    Remove-Item "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
}


# =====================================================
# ULTRA UI
# =====================================================

Write-Host "Applying UltraUI Tweaks..."

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
/v AllowTelemetry /t REG_DWORD /d 0 /f

sc stop DiagTrack 2>$null
sc config DiagTrack start= disabled


# ---------- CLEAN ----------
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

cleanmgr /verylowdisk
ipconfig /flushdns


# =====================================================
# FINISH
# =====================================================

Write-Host ""
Write-Host "ULTRA S+ COMPLETE ✓" -ForegroundColor Green
Write-Host "Restarting in 5 seconds..."

Start-Sleep 5
shutdown /r /t 0

}
catch {
Write-Host "===== ERROR =====" -ForegroundColor Red
Write-Host $_
Pause-End
}

}
