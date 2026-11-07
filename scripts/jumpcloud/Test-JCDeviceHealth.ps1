#Requires -Version 7.0

<#
.SYNOPSIS
    Finds JumpCloud devices that have not contacted JumpCloud recently.

.DESCRIPTION
    Checks the lastContact value for every JumpCloud device and
    identifies devices that have not contacted JumpCloud for more
    than the configured number of days.

    This demonstrates how PowerShell can automate a repetitive
    daily device-health check.

.NOTES
    Requires:
      - PowerShell 7+
      - JumpCloud PowerShell module
      - Authenticated Connect-JCOnline session
#>

$ErrorActionPreference = "Stop"

$DaysInactive = 7

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " JUMPCLOUD DEVICE HEALTH CHECK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$CutoffDate = (Get-Date).AddDays(-$DaysInactive)

Write-Host "Checking for devices inactive since:"
Write-Host $CutoffDate
Write-Host ""

$Systems = @(Get-JCSystem)

$InactiveSystems = @(
    $Systems | Where-Object {
        $_.lastContact -and
        ([datetime]$_.lastContact -lt $CutoffDate)
    }
)

if ($InactiveSystems.Count -eq 0) {
    Write-Host "All devices are active." -ForegroundColor Green
}
else {
    Write-Host "Devices requiring attention:" -ForegroundColor Red
    Write-Host ""

    $InactiveSystems |
        Select-Object displayName, osFamily, lastContact |
        Format-Table -AutoSize

    Write-Host ""
    Write-Host "Total inactive devices: $($InactiveSystems.Count)" -ForegroundColor Red
}