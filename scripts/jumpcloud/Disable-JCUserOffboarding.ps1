#Requires -Version 7.0

<#
.SYNOPSIS
    Suspends a JumpCloud user as part of an employee offboarding process.

.DESCRIPTION
    Automates the first stage of a JumpCloud user offboarding process.

    The script:
      1. Checks whether the username exists.
      2. Checks the user's current state.
      3. Suspends the user if they are not already suspended.
      4. Produces an offboarding summary.

    The script is idempotent:
    running it again will not repeatedly modify an already
    suspended user.

    The script uses -WhatIf support so changes can be safely
    tested before being applied.

.NOTES
    Requires:
      - PowerShell 7+
      - JumpCloud PowerShell module
      - Authenticated Connect-JCOnline session
#>

[CmdletBinding(SupportsShouldProcess)]
param (

    [Parameter(Mandatory)]
    [string]$Username
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " JUMPCLOUD USER OFFBOARDING" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# 1. Display offboarding information
# ------------------------------------------------------------

Write-Host "Offboarding Information" -ForegroundColor Yellow
Write-Host "-----------------------"
Write-Host "Username : $Username"
Write-Host ""

# ------------------------------------------------------------
# 2. Find the JumpCloud user
# ------------------------------------------------------------

Write-Host "Checking whether user exists..." -ForegroundColor Yellow

$ExistingUser = @(Get-JCUser | Where-Object {
    $_.username -eq $Username
})

if ($ExistingUser.Count -eq 0) {

    Write-Host ""
    Write-Host "USER NOT FOUND" -ForegroundColor Red
    Write-Host "Username: $Username" -ForegroundColor Red
    Write-Host ""
    Write-Host "No changes were made." -ForegroundColor Yellow

    exit
}

$User = $ExistingUser[0]

Write-Host "User found." -ForegroundColor Green
Write-Host ""

# ------------------------------------------------------------
# 3. Display current user state
# ------------------------------------------------------------

Write-Host "Current User State" -ForegroundColor Yellow
Write-Host "------------------"
Write-Host "Name      : $($User.firstname) $($User.lastname)"
Write-Host "Username  : $($User.username)"
Write-Host "Email     : $($User.email)"
Write-Host "Department: $($User.department)"
Write-Host "Job Title : $($User.jobTitle)"
Write-Host "State     : $($User.state)"
Write-Host ""

# ------------------------------------------------------------
# 4. Check whether the user is already suspended
# ------------------------------------------------------------

if ($User.state -eq "SUSPENDED") {

    Write-Host "USER ALREADY SUSPENDED" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "No changes were made." -ForegroundColor Green

    exit
}

# ------------------------------------------------------------
# 5. Suspend the user
# ------------------------------------------------------------

Write-Host "Suspending JumpCloud user..." -ForegroundColor Yellow

if ($PSCmdlet.ShouldProcess(
        $Username,
        "Suspend JumpCloud user"
    )) {

    Set-JCUser `
        -Username $Username `
        -state SUSPENDED

    Write-Host ""
    Write-Host "User suspended successfully." -ForegroundColor Green
}
else {

    Write-Host ""
    Write-Host "WhatIf mode: user was NOT suspended." `
        -ForegroundColor Yellow

    exit
}

# ------------------------------------------------------------
# 6. Offboarding summary
# ------------------------------------------------------------

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " OFFBOARDING COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "User     : $($User.firstname) $($User.lastname)" `
    -ForegroundColor Green

Write-Host "Username : $Username" -ForegroundColor Green

Write-Host "Email    : $($User.email)" -ForegroundColor Green

Write-Host "Previous State: $($User.state)" `
    -ForegroundColor Yellow

Write-Host "New State     : SUSPENDED" `
    -ForegroundColor Green

Write-Host ""
Write-Host "JumpCloud access has been revoked." `
    -ForegroundColor Green

Write-Host ""
Write-Host "User offboarding completed successfully." `
    -ForegroundColor Green

Write-Host ""
