#Requires -Version 7.0

<#
.SYNOPSIS
    Creates a daily JumpCloud device inventory report.

.DESCRIPTION
    Retrieves all JumpCloud systems and exports useful device
    information to a dated CSV report.

    This demonstrates how PowerShell can automate repetitive
    daily administration tasks.

.NOTES
    Requires:
      - PowerShell 7+
      - JumpCloud PowerShell module
      - Authenticated Connect-JCOnline session
#>

$ErrorActionPreference = "Stop"

$ReportFolder = "$HOME/Desktop/JumpCloud-Reports"

if (-not (Test-Path -Path $ReportFolder)) {
    New-Item -Path $ReportFolder -ItemType Directory | Out-Null
}

$Date = Get-Date -Format "yyyy-MM-dd"
$ReportPath = Join-Path $ReportFolder "JumpCloud-Device-Inventory-$Date.csv"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " JUMPCLOUD DAILY DEVICE INVENTORY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$Systems = @(Get-JCSystem)

$Report = $Systems | Select-Object displayName, osFamily, osVersion, model, serialNumber, lastContact

$Report | Export-Csv -Path $ReportPath -NoTypeInformation

Write-Host "Devices found: $($Systems.Count)" -ForegroundColor Green
Write-Host ""
Write-Host "Report created:" -ForegroundColor Green
Write-Host $ReportPath
Write-Host ""