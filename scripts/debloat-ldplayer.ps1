<#
.SYNOPSIS
    EmuPure - LDPlayer 9 Debloater & Optimizer
.DESCRIPTION
    Automates LDPlayer debloating:
    - Disables flysilkworm adware launcher / services
    - Removes Chinese keyboard telemetry
    - Injects ad-blocking hosts
#>

[CmdletBinding()]
param (
    [string]$CustomAdbPath = "",
    [int]$Port = 5555
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "    EmuPure: LDPlayer 9 Debloater & Optimizer" -ForegroundColor Green
Write-Host "    https://github.com/zliveze/EmuPure" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

$adbCandidates = @(
    $CustomAdbPath,
    "C:\LDPlayer\LDPlayer9\adb.exe",
    "D:\LDPlayer\LDPlayer9\adb.exe",
    (Get-Command adb -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source)
) | Where-Object { $_ -and (Test-Path $_) }

if ($adbCandidates.Count -eq 0) {
    Write-Error "Could not locate adb.exe for LDPlayer."
    return
}
$adb = $adbCandidates[0]
$targetDevice = "127.0.0.1:$Port"

Write-Host "[+] Using ADB: $adb" -ForegroundColor Green
& $adb connect $targetDevice | Out-Null
& $adb -s $targetDevice root | Out-Null

$ldBloat = @(
    "com.android.flysilkworm",
    "com.google.android.inputmethod.pinyin",
    "com.cyanogenmod.filemanager",
    "com.android.adservices.api"
)

Write-Host "`n[*] Disabling LDPlayer bloatware..." -ForegroundColor Cyan
foreach ($pkg in $ldBloat) {
    Write-Host "    [-] Disabling $pkg... " -NoNewline
    & $adb -s $targetDevice shell "pm disable-user --user 0 $pkg 2>/dev/null; am force-stop $pkg 2>/dev/null"
    Write-Host "DONE" -ForegroundColor Green
}

Write-Host "`n[+] LDPlayer debloated successfully." -ForegroundColor Green
