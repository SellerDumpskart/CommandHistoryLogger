#Requires -RunAsAdministrator

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "  CommandHistory Logger v3 -- Setup" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

$root   = "C:\CommandHistory"
$system = "$root\_system"
$src    = Split-Path $PSCommandPath -Parent

Write-Host "[1/6] Creating folders..." -ForegroundColor Yellow
@($root,"$root\_system","$root\TXT","$root\HTML","$root\CSV") | ForEach-Object {
    New-Item -ItemType Directory -Path $_ -Force | Out-Null
}
Write-Host "      OK" -ForegroundColor Green

Write-Host "[2/6] Copying core files..." -ForegroundColor Yellow
Copy-Item "$src\system\CommandLogger.ps1" "$system\CommandLogger.ps1" -Force
Write-Host "      OK" -ForegroundColor Green

Write-Host "[3/6] Setting execution policy..." -ForegroundColor Yellow
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force -ErrorAction SilentlyContinue
Write-Host "      OK" -ForegroundColor Green

Write-Host "[4/6] Installing PowerShell profile..." -ForegroundColor Yellow
$profilePath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\profile.ps1"
$block = @"

# -- CommandHistoryLogger --
if (-not `$Global:CHL_Loaded) {
    `$Global:CHL_Loaded = `$true
    if (Test-Path "C:\CommandHistory\_system\CommandLogger.ps1") {
        try { . "C:\CommandHistory\_system\CommandLogger.ps1" } catch {}
    }
}
# -- End CommandHistoryLogger --
"@
if (Test-Path $profilePath) {
    $existing = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
    if ($existing -notmatch "CommandHistoryLogger") {
        Add-Content $profilePath $block -Encoding UTF8
    } else {
        Write-Host "      Already installed" -ForegroundColor Gray
    }
} else {
    Set-Content $profilePath $block -Encoding UTF8
}
Write-Host "      OK" -ForegroundColor Green

Write-Host "[5/6] Setting PSReadLine colors (white for light terminal)..." -ForegroundColor Yellow
$colorLine = "Set-PSReadLineOption -Colors @{ Command = 'White'; Parameter = 'White'; Operator = 'White'; Variable = 'White'; String = 'White'; Number = 'White'; Member = 'White'; Keyword = 'White' }"
$profileContent = if (Test-Path $profilePath) { Get-Content $profilePath -Raw -ErrorAction SilentlyContinue } else { "" }
if ($profileContent -notmatch "Set-PSReadLineOption") {
    Add-Content $profilePath "`n$colorLine" -Encoding UTF8
} else {
    Write-Host "      Already installed" -ForegroundColor Gray
}
Write-Host "      OK" -ForegroundColor Green

Write-Host "[6/6] Setting CMD AutoRun registry key..." -ForegroundColor Yellow
$autoRun = "powershell.exe -NoLogo -ExecutionPolicy Bypass -NoExit -File `"C:\CommandHistory\_system\CommandLogger.ps1`""
$regPath = "HKLM:\Software\Microsoft\Command Processor"
if (-not (Test-Path $regPath)) { New-Item $regPath -Force | Out-Null }
Set-ItemProperty $regPath -Name AutoRun -Value $autoRun -Type String
Remove-ItemProperty "HKCU:\Software\Microsoft\Command Processor" -Name AutoRun -ErrorAction SilentlyContinue
Write-Host "      OK" -ForegroundColor Green

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "  DONE -- Close and reopen terminal to start logging" -ForegroundColor Green
Write-Host "  Logs saved to: C:\CommandHistory\" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""
