<#
.SYNOPSIS
    EmuPure - Universal Android Emulator Debloater & Optimizer
.DESCRIPTION
    Main CLI entrypoint for EmuPure.
    Auto-detects running emulators or allows manual selection.
    https://github.com/zliveze/EmuPure
#>

[CmdletBinding()]
param (
    [ValidateSet("auto", "mumu", "ldplayer", "bluestacks", "hosts")]
    [string]$Target = "auto"
)

$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$scriptsDir = Join-Path $PSScriptRoot "scripts"

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  ______                 _____                  " -ForegroundColor Green
Write-Host " |  ____|               |  __ \                 " -ForegroundColor Green
Write-Host " | |__   _ __ ___  _   _| |__) |   _ _ __ ___   " -ForegroundColor Green
Write-Host " |  __| | '_ ` _ \| | | |  ___/ | | | '__/ _ \  " -ForegroundColor Green
Write-Host " | |____| | | | | | |_| | |   | |_| | | |  __/  " -ForegroundColor Green
Write-Host " |______|_| |_| |_|\__,_|_|    \__,_|_|  \___|  " -ForegroundColor Green
Write-Host "                                                        "
Write-Host "  Zero Bloat. Zero Ads. Pure Performance for Emulators.  " -ForegroundColor Yellow
Write-Host "  Author: zliveze (https://github.com/zliveze/EmuPure)  " -ForegroundColor DarkGray
Write-Host "==========================================================" -ForegroundColor Cyan

# Detection logic
function Detect-RunningEmulator {
    $proc = Get-Process | Where-Object { $_.ProcessName -match "MuMuNx|MuMuPlayer|dnplayer|HD-Player|Nox" } | Select-Object -First 1
    if (-not $proc) { return $null }
    
    switch -Regex ($proc.ProcessName) {
        "MuMu"      { return "mumu" }
        "dnplayer"  { return "ldplayer" }
        "HD-Player" { return "bluestacks" }
        "Nox"       { return "nox" }
        default     { return $null }
    }
}

if ($Target -eq "auto") {
    $detected = Detect-RunningEmulator
    if ($detected) {
        Write-Host "`n[+] Auto-detected running emulator: $($detected.ToUpper())" -ForegroundColor Green
        $choice = $detected
    } else {
        Write-Host "`n[!] No active emulator automatically detected." -ForegroundColor Yellow
        Write-Host "Select an emulator to debloat:"
        Write-Host "  [1] MuMu Player 12 / Nx"
        Write-Host "  [2] LDPlayer 9"
        Write-Host "  [3] BlueStacks 5"
        Write-Host "  [4] Update Windows Hosts (Adblock)"
        Write-Host "  [Q] Exit"
        $inputVal = Read-Host "`nEnter option [1-4]"
        switch ($inputVal) {
            "1" { $choice = "mumu" }
            "2" { $choice = "ldplayer" }
            "3" { $choice = "bluestacks" }
            "4" { $choice = "hosts" }
            default { exit 0 }
        }
    }
} else {
    $choice = $Target
}

switch ($choice) {
    "mumu" {
        & (Join-Path $scriptsDir "debloat-mumu.ps1")
    }
    "ldplayer" {
        & (Join-Path $scriptsDir "debloat-ldplayer.ps1")
    }
    "bluestacks" {
        & (Join-Path $scriptsDir "debloat-bluestacks.ps1")
    }
    "hosts" {
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$scriptsDir\update-windows-hosts.bat`"" -Verb RunAs
    }
}

