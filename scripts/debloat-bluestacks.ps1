<#
.SYNOPSIS
    EmuPure - BlueStacks 5 Debloater & Optimizer
.DESCRIPTION
    Automates BlueStacks 5 debloating:
    - Disables Gamepedia & telemetry ads
    - Disables background recommendations
#>

[CmdletBinding()]
param (
    [string]$CustomAdbPath = "",
    [int]$Port = 5555
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "    EmuPure: BlueStacks 5 Debloater & Optimizer" -ForegroundColor Green
Write-Host "    https://github.com/zliveze/EmuPure" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

$adbCandidates = @(
    $CustomAdbPath,
    "C:\Program Files\BlueStacks_nxt\HD-Adb.exe",
    (Get-Command adb -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source)
) | Where-Object { $_ -and (Test-Path $_) }

if ($adbCandidates.Count -eq 0) {
    Write-Error "Could not locate HD-Adb.exe or adb.exe for BlueStacks."
    return
}
$adb = $adbCandidates[0]
$targetDevice = "127.0.0.1:$Port"

Write-Host "[+] Using ADB: $adb" -ForegroundColor Green
& $adb connect $targetDevice | Out-Null
& $adb -s $targetDevice root | Out-Null

$bsBloat = @(
    "com.bluestacks.gamepedia",
    "com.bluestacks.settings",
    "com.android.adservices.api"
)

Write-Host "`n[*] Disabling BlueStacks bloatware..." -ForegroundColor Cyan
foreach ($pkg in $bsBloat) {
    Write-Host "    [-] Disabling $pkg... " -NoNewline
    & $adb -s $targetDevice shell "pm disable-user --user 0 $pkg 2>/dev/null; am force-stop $pkg 2>/dev/null"
    Write-Host "DONE" -ForegroundColor Green
}

Write-Host "`n[+] BlueStacks debloated successfully." -ForegroundColor Green

