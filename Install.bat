@echo off
:: =====================================================
::  CommandHistory Logger v3 -- One-Click Installer
::  Downloads from GitHub and installs automatically
:: =====================================================

:: Check for Admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  ERROR: Run this as Administrator!
    echo  Right-click Install.bat and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo.
echo =====================================================
echo   CommandHistory Logger v3 -- One-Click Installer
echo =====================================================
echo.

:: ---- CONFIGURE YOUR GITHUB REPO HERE ----
set "REPO=SellerDumpskart/CommandHistoryLogger"
set "BRANCH=main"
set "BASE_URL=https://raw.githubusercontent.com/%REPO%/%BRANCH%"
:: ------------------------------------------

set "TEMP_DIR=C:\CommandHistoryLogger_temp"

:: Step 1: Set temporary CMD AutoRun
echo [1/8] Setting temporary CMD AutoRun...
reg add "HKLM\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d "powershell.exe -NoLogo -NoProfile" /f >nul 2>&1
echo       OK

:: Step 2: Set execution policy
echo [2/8] Setting execution policy...
powershell.exe -NoLogo -NoProfile -Command "Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force"
echo       OK

:: Step 3: Create temp folder
echo [3/8] Creating temp folder...
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%" >nul 2>&1
mkdir "%TEMP_DIR%" >nul 2>&1
mkdir "%TEMP_DIR%\system" >nul 2>&1
echo       OK

:: Step 4: Download files from GitHub
echo [4/8] Downloading from GitHub...
powershell.exe -NoLogo -NoProfile -Command ^
    "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; " ^
    "try { " ^
    "  Invoke-WebRequest -Uri '%BASE_URL%/system/CommandLogger.ps1' -OutFile '%TEMP_DIR%\system\CommandLogger.ps1' -UseBasicParsing; " ^
    "  Invoke-WebRequest -Uri '%BASE_URL%/Setup.ps1' -OutFile '%TEMP_DIR%\Setup.ps1' -UseBasicParsing; " ^
    "  Write-Host '      OK' " ^
    "} catch { " ^
    "  Write-Host '      FAILED - Check internet connection and repo URL' -ForegroundColor Red; " ^
    "  exit 1 " ^
    "}"
if not exist "%TEMP_DIR%\Setup.ps1" (
    echo       FAILED - Could not download files
    echo       Check that repo URL is correct: %REPO%
    rmdir /s /q "%TEMP_DIR%" >nul 2>&1
    pause
    exit /b 1
)
if not exist "%TEMP_DIR%\system\CommandLogger.ps1" (
    echo       FAILED - Could not download CommandLogger.ps1
    rmdir /s /q "%TEMP_DIR%" >nul 2>&1
    pause
    exit /b 1
)

:: Step 5: Run Setup.ps1
echo [5/8] Running Setup...
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "& '%TEMP_DIR%\Setup.ps1'"
echo       OK

:: Step 6: Verify registry
echo [6/8] Verifying installation...
reg query "HKLM\Software\Microsoft\Command Processor" /v AutoRun | findstr /i "CommandLogger" >nul 2>&1
if %errorlevel% neq 0 (
    echo       WARNING - Registry not updated. Setup may have failed.
    pause
    exit /b 1
)
if not exist "C:\CommandHistory\_system\CommandLogger.ps1" (
    echo       WARNING - CommandLogger.ps1 not found. Setup may have failed.
    pause
    exit /b 1
)
echo       OK

:: Step 7: Cleanup
echo [7/8] Cleaning up...
rmdir /s /q "%TEMP_DIR%" >nul 2>&1
echo       OK

echo [8/8] Installation complete!
echo.
echo =====================================================
echo   DONE -- Close and reopen terminal to start logging
echo   Logs saved to: C:\CommandHistory\
echo =====================================================
echo.
echo   Features:
echo   - Commands logged to TXT, HTML, CSV (day-wise)
echo   - Session detection (DWAgent, MeshCentral, SSH, RDP)
echo   - CMD auto-launches PowerShell with logger
echo   - cd works without quotes (cd program files)
echo   - White text colors for light terminals
echo   - Clean prompt without PS prefix
echo.
pause
