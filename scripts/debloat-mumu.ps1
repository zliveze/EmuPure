<#
.SYNOPSIS
    EmuPure - MuMu Player 12 / Nx Debloater & Optimizer
.DESCRIPTION
    Automates MuMu Player debloating:
    - Auto-detects MuMu ADB binary and port (16384 / 7555)
    - Disables bloatware and ad services
    - Removes fake app ads & promotional shortcuts from Lawnchair launcher
    - Injects ad-blocking hosts into Android
    - Installs KernelSU boot persistence script
    - Tunes animation speeds for competitive gaming
#>

[CmdletBinding()]
param (
    [string]$CustomAdbPath = "",
    [int]$Port = 16384
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "    EmuPure: MuMu Player Debloater & Optimizer" -ForegroundColor Green
Write-Host "    https://github.com/zliveze/EmuPure" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Locate ADB
$adbCandidates = @(
    $CustomAdbPath,
    "D:\Program Files\Netease\MuMuPlayer\nx_device\15.0\shell\adb.exe",
    "C:\Program Files\Netease\MuMuPlayer\nx_device\15.0\shell\adb.exe",
    "D:\Program Files\Netease\MuMuPlayer\nx_main\adb.exe",
    "C:\Program Files\Netease\MuMuPlayer\nx_main\adb.exe",
    (Get-Command adb -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source)
) | Where-Object { $_ -and (Test-Path $_) }

if ($adbCandidates.Count -eq 0) {
    Write-Error "Could not locate adb.exe. Please ensure MuMu Player is installed or specify -CustomAdbPath."
    return
}
$adb = $adbCandidates[0]
Write-Host "[+] Using ADB: $adb" -ForegroundColor Green

# 2. Connect to MuMu ADB Port
$targetDevice = "127.0.0.1:$Port"
Write-Host "[*] Connecting to $targetDevice..." -ForegroundColor Cyan
& $adb connect $targetDevice | Out-Null
Start-Sleep -Seconds 1

# Check device connection
$devices = & $adb devices
if ($devices -notmatch $targetDevice) {
    # Try fallback port 7555
    $targetDevice = "127.0.0.1:7555"
    Write-Host "[!] Port $Port failed. Trying fallback port $targetDevice..." -ForegroundColor Yellow
    & $adb connect $targetDevice | Out-Null
    Start-Sleep -Seconds 1
}

# 3. Elevate to root
Write-Host "[*] Requesting root access..." -ForegroundColor Cyan
& $adb -s $targetDevice root | Out-Null
Start-Sleep -Seconds 2

$idOut = & $adb -s $targetDevice shell id
if ($idOut -notmatch "uid=0") {
    Write-Warning "Could not obtain root. Some system debloat actions might require root enabled in MuMu settings."
} else {
    Write-Host "[+] Root access granted (uid=0)." -ForegroundColor Green
}

# 4. Disable Bloatware Packages
# CRITICAL: com.android.sdksandbox must NEVER be disabled on Android 15.
# PackageManagerService requires exactly one SDK sandbox package at boot;
# disabling it crash-loops system_server and MuMu Player hangs at 98%.
$bloatPackages = @(
    "com.mumu.store",
    "com.mumu.acc",
    "com.nemu.oaidmanager",
    "com.mumu.shared.sdk",
    "com.netease.mumu.cloner",
    "com.android.adservices.api",
    "com.android.ondevicepersonalization.services",
    "com.android.federatedcompute.services"
)

Write-Host "`n[*] Self-healing boot-critical packages..." -ForegroundColor Cyan
& $adb -s $targetDevice shell "pm enable com.android.sdksandbox 2>/dev/null" | Out-Null
Write-Host "    [+] com.android.sdksandbox ensured ENABLED (required by Android 15)." -ForegroundColor Green

Write-Host "`n[*] Disabling bloatware packages..." -ForegroundColor Cyan
foreach ($pkg in $bloatPackages) {
    Write-Host "    [-] Disabling $pkg... " -NoNewline
    & $adb -s $targetDevice shell "pm disable-user --user 0 $pkg 2>/dev/null; am force-stop $pkg 2>/dev/null"
    Write-Host "DONE" -ForegroundColor Green
}

# 5. Clean Launcher Home Screen (Remove Fake Ads)
Write-Host "`n[*] Purging adware shortcuts from Lawnchair launcher..." -ForegroundColor Cyan
$launcherDb = "/data/data/app.lawnchair/databases/launcher_4_7_4_1.db"
$cleanSql = "DELETE FROM favorites WHERE intent LIKE '%easebar%' OR intent LIKE '%mumu.store%' OR intent LIKE '%Arknights%';"
$tempSql = "$env:TEMP\emupure_clean.sql"
[System.IO.File]::WriteAllText($tempSql, $cleanSql)
& $adb -s $targetDevice push $tempSql /data/local/tmp/emupure_clean.sql | Out-Null
& $adb -s $targetDevice shell "sqlite3 $launcherDb < /data/local/tmp/emupure_clean.sql 2>/dev/null; rm -f /data/local/tmp/emupure_clean.sql"
Remove-Item $tempSql -ErrorAction SilentlyContinue
& $adb -s $targetDevice shell "am force-stop app.lawnchair 2>/dev/null"
Write-Host "[+] Launcher database cleaned & refreshed." -ForegroundColor Green

# 6. Apply Ad-Blocking Hosts inside Android
Write-Host "`n[*] Injecting ad-blocking hosts into Android..." -ForegroundColor Cyan
$hostsContent = @"
127.0.0.1 localhost
::1 ip6-localhost
0.0.0.0 mumu-global.fp.ps.easebar.com
0.0.0.0 store-api.mumuglobal.com
0.0.0.0 adl.easebar.com
0.0.0.0 hub.mumuglobal.com
0.0.0.0 notice.mumuglobal.com
0.0.0.0 adlog.mumuglobal.com
0.0.0.0 report.mumu.163.com
0.0.0.0 api.mumu.163.com
"@ -replace "`r`n", "`n"

$tempHosts = "$env:TEMP\mumu_hosts.txt"
[System.IO.File]::WriteAllText($tempHosts, $hostsContent)
& $adb -s $targetDevice push $tempHosts /data/adb/hosts | Out-Null
& $adb -s $targetDevice shell "chmod 644 /data/adb/hosts && mount -o bind /data/adb/hosts /system/etc/hosts 2>/dev/null"
Remove-Item $tempHosts -ErrorAction SilentlyContinue
Write-Host "[+] Android /system/etc/hosts successfully bound." -ForegroundColor Green

# 7. Install KernelSU Persistent Boot Script
Write-Host "`n[*] Installing boot persistence service (/data/adb/service.d/debloat.sh)..." -ForegroundColor Cyan
$bootScript = @'
#!/system/bin/sh
sleep 5
# SELF-HEAL: com.android.sdksandbox must stay enabled on Android 15.
# Disabling it crash-loops system_server (MuMu stuck at 98%).
pm enable com.android.sdksandbox >/dev/null 2>&1
if [ -f /data/adb/hosts ]; then
    mount -o bind /data/adb/hosts /system/etc/hosts
fi
PACKAGES="com.mumu.store com.mumu.acc com.nemu.oaidmanager com.mumu.shared.sdk com.netease.mumu.cloner com.android.adservices.api com.android.ondevicepersonalization.services com.android.federatedcompute.services"
for pkg in $PACKAGES; do
    pm disable-user --user 0 $pkg >/dev/null 2>&1
    am force-stop $pkg >/dev/null 2>&1
done
if [ -f /data/data/app.lawnchair/databases/launcher_4_7_4_1.db ]; then
    sqlite3 /data/data/app.lawnchair/databases/launcher_4_7_4_1.db "DELETE FROM favorites WHERE intent LIKE '%easebar%' OR intent LIKE '%mumu.store%' OR intent LIKE '%Arknights%';" >/dev/null 2>&1
fi
'@ -replace "`r`n", "`n"

$tempScript = "$env:TEMP\debloat.sh"
[System.IO.File]::WriteAllText($tempScript, $bootScript)
& $adb -s $targetDevice shell "mkdir -p /data/adb/service.d" | Out-Null
& $adb -s $targetDevice push $tempScript /data/adb/service.d/debloat.sh | Out-Null
& $adb -s $targetDevice shell "chmod 755 /data/adb/service.d/debloat.sh" | Out-Null
Remove-Item $tempScript -ErrorAction SilentlyContinue
Write-Host "[+] Boot persistence installed. Settings will persist across all reboots." -ForegroundColor Green

# 8. Optimize Gaming Performance Settings
Write-Host "`n[*] Tuning animation scales for zero latency..." -ForegroundColor Cyan
& $adb -s $targetDevice shell "settings put global window_animation_scale 0.5"
& $adb -s $targetDevice shell "settings put global transition_animation_scale 0.5"
& $adb -s $targetDevice shell "settings put global animator_duration_scale 0.5"
Write-Host "[+] Animation scales set to 0.5x." -ForegroundColor Green

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "[SUCCESS] MuMu Player debloated and optimized successfully!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

