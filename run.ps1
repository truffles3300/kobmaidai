
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
    Set-PSReadLineOption -HistorySaveStyle SaveNothing
    Clear-History
}

Set-Location -Path $PSScriptRoot

$exe = Join-Path $PSScriptRoot "DemoCrack.exe"

if (-not (Test-Path $exe)) {
    Write-Error "ไม่พบไฟล์ DemoCrack.exe"
    exit 1
}


$proc = Start-Process -FilePath $exe -PassThru
$proc.WaitForExit()

$me = $MyInvocation.MyCommand.Path
Start-Process powershell -ArgumentList "-NoProfile -WindowStyle Hidden -Command Start-Sleep 1; Remove-Item -LiteralPath '$me' -Force" -WindowStyle Hidden
