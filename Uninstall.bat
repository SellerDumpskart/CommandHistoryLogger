@echo off
:: =====================================================
::  CommandHistory Logger v3 -- Uninstaller
:: =====================================================

:: Check for Admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  ERROR: Run this as Administrator!
    echo  Right-click Uninstall.bat and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo.
echo =====================================================
echo   CommandHistory Logger v3 -- Uninstaller
echo =====================================================
echo.
echo   This will:
echo   - Remove CMD AutoRun registry key
echo   - Remove CommandLogger from PowerShell profile
echo   - Remove C:\CommandHistory\_system folder
echo.
set /p confirm="  Continue? (Y/N): "
if /i not "%confirm%"=="Y" (
    echo   Cancelled.
    pause
    exit /b 0
)

echo.
set /p dellogs="  Also delete all log files? (Y/N): "
echo.

:: Step 1: Remove CMD AutoRun
echo [1/4] Removing CMD AutoRun registry key...
reg delete "HKLM\Software\Microsoft\Command Processor" /v AutoRun /f >nul 2>&1
echo       OK

:: Step 2: Clean PowerShell profile
echo [2/4] Cleaning PowerShell profile...
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
    "$p = \"$env:SystemRoot\System32\WindowsPowerShell\v1.0\profile.ps1\"; " ^
    "if (Test-Path $p) { " ^
    "  $lines = Get-Content $p; " ^
    "  $skip = $false; " ^
    "  $clean = @(); " ^
    "  foreach ($line in $lines) { " ^
    "    if ($line -match 'CommandHistoryLogger') { $skip = $true } " ^
    "    if (-not $skip) { $clean += $line } " ^
    "    if ($line -match 'End CommandHistoryLogger') { $skip = $false } " ^
    "  }; " ^
    "  $clean = $clean | Where-Object { $_ -notmatch 'Set-PSReadLineOption' }; " ^
    "  Set-Content $p ($clean -join \"`n\") -Encoding UTF8 " ^
    "}"
echo       OK

:: Step 3: Remove system folder
echo [3/4] Removing system files...
if exist "C:\CommandHistory\_system" (
    rmdir /s /q "C:\CommandHistory\_system" >nul 2>&1
)
echo       OK

:: Step 4: Delete logs if requested
if /i "%dellogs%"=="Y" (
    echo [4/5] Deleting log files...
    if exist "C:\CommandHistory" rmdir /s /q "C:\CommandHistory" >nul 2>&1
    echo       OK
    echo [5/5] Done!
) else (
    echo [4/4] Done!
)

echo.
:: Cleanup uninstaller
del /f "C:\Uninstall.bat" >nul 2>&1
echo =====================================================
echo   UNINSTALLED
if /i not "%dellogs%"=="Y" (
    echo.
    echo   Your logs are still in:
    echo     C:\CommandHistory\TXT\
    echo     C:\CommandHistory\HTML\
    echo     C:\CommandHistory\CSV\
)
echo =====================================================
echo.
pause
