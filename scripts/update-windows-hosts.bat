@echo off
chcp 65001 >nul
:: ========================================================
:: EmuPure - Windows Hosts Ad Blocker for Emulators
:: https://github.com/zliveze/EmuPure
:: ========================================================
title EmuPure - Update Windows Hosts
color 0A

echo ========================================================
echo   EmuPure: Update Windows Hosts for Android Emulators
echo ========================================================
echo.

openfiles >nul 2>&1
if %errorlevel% NEQ 0 (
    echo [!] ERROR: Administrator privileges required!
    echo [!] Please right-click this file and select "Run as administrator".
    echo.
    pause
    exit /b 1
)

set HOSTS_FILE=%WINDIR%\System32\drivers\etc\hosts

echo [*] Checking %HOSTS_FILE%...
findstr /C:"mumu-global.fp.ps.easebar.com" "%HOSTS_FILE%" >nul
if %errorlevel% NEQ 0 (
    echo.>> "%HOSTS_FILE%"
    echo # === EmuPure Emulator Ad Blocking ===>> "%HOSTS_FILE%"
    echo 0.0.0.0 mumu-global.fp.ps.easebar.com>> "%HOSTS_FILE%"
    echo 0.0.0.0 store-api.mumuglobal.com>> "%HOSTS_FILE%"
    echo 0.0.0.0 adl.easebar.com>> "%HOSTS_FILE%"
    echo 0.0.0.0 hub.mumuglobal.com>> "%HOSTS_FILE%"
    echo 0.0.0.0 ad.ldmnq.com>> "%HOSTS_FILE%"
    echo 0.0.0.0 admarket.ldmnq.com>> "%HOSTS_FILE%"
    echo 0.0.0.0 ads.bluestacks.com>> "%HOSTS_FILE%"
    echo 0.0.0.0 api.bignox.com>> "%HOSTS_FILE%"
    echo [+] Successfully added emulator ad-blocking entries to Hosts!
) else (
    echo [i] Emulator entries already exist in Hosts file. Skipping append.
)

echo [*] Flushing Windows DNS Cache...
ipconfig /flushdns >nul
echo [+] Done! Hosts file has been updated and DNS refreshed.
echo.
pause

