#Requires -Version 7.0

<#
.SYNOPSIS
    Creates and configures a new JumpCloud user.

.DESCRIPTION
    Automates a basic employee onboarding process in JumpCloud.

    The script:
      1. Checks whether the username already exists.
      2. Creates the JumpCloud user if they do not exist.
      3. Sets employee attributes.
      4. Adds the user to specified JumpCloud user groups.
      5. Displays an onboarding summary.

    The script is idempotent:
    running it again will not create a duplicate user.

.NOTES
    Requires:
      - PowerShell 7+
      - JumpCloud PowerShell module
      - Authenticated Connect-JCOnline session
#>

[CmdletBinding(SupportsShouldProcess)]
param (

    [Parameter(Mandatory)]
    [string]$FirstName,

    [Parameter(Mandatory)]
    [string]$LastName,

    [Parameter(Mandatory)]
    [string]$Username,

    [Parameter(Mandatory)]
    [string]$Email,

    [Parameter(Mandatory)]
    [string]$Department,

    [Parameter(Mandatory)]
    [string]$JobTitle,

    [Parameter(Mandatory)]
    [string]$Location,

    [Parameter(Mandatory)]
    [string]$EmployeeType,

    [string[]]$Groups
)

$ErrorActionPreference = "Stop"

$AssignedGroups = @()
$SkippedGroups = @()

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " JUMPCLOUD USER ONBOARDING" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# 1. Display onboarding information
# ------------------------------------------------------------

Write-Host "Employee Information" -ForegroundColor Yellow
Write-Host "--------------------"
Write-Host "Name          : $FirstName $LastName"
Write-Host "Username      : $Username"
Write-Host "Email         : $Email"
Write-Host "Department    : $Department"
Write-Host "Job Title     : $JobTitle"
Write-Host "Location      : $Location"
Write-Host "Employee Type : $EmployeeType"
Write-Host ""

# ------------------------------------------------------------
# 2. Check whether the user already exists
# ------------------------------------------------------------

Write-Host "Checking whether user already exists..." -ForegroundColor Yellow

$ExistingUser = @(Get-JCUser | Where-Object {
    $_.username -eq $Username
})

if ($ExistingUser.Count -gt 0) {

    Write-Host ""
    Write-Host "USER ALREADY EXISTS" -ForegroundColor Yellow
    Write-Host "Username: $Username" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "No new account was created." -ForegroundColor Green

    exit
}

Write-Host "User does not exist." -ForegroundColor Green
Write-Host ""

# ------------------------------------------------------------
# 3. Create the JumpCloud user
# ------------------------------------------------------------

Write-Host "Creating JumpCloud user..." -ForegroundColor Yellow

if ($PSCmdlet.ShouldProcess(
        $Username,
        "Create JumpCloud user"
    )) {

    New-JCUser `
        -username $Username `
        -email $Email `
        -firstname $FirstName `
        -lastname $LastName `
        -department $Department `
        -jobTitle $JobTitle `
        -location $Location `
        -employeeType $EmployeeType

    Write-Host ""
    Write-Host "User created successfully." -ForegroundColor Green
}
else {

    Write-Host ""
    Write-Host "WhatIf mode: user was NOT created." -ForegroundColor Yellow

    exit
}

# ------------------------------------------------------------
# 4. Add user to JumpCloud groups
# ------------------------------------------------------------

if ($Groups) {

    Write-Host ""
    Write-Host "Processing group memberships..." -ForegroundColor Yellow

    foreach ($GroupName in $Groups) {

        Write-Host ""
        Write-Host "Checking group: $GroupName"

        $GroupExists = @(Get-JCUserGroup | Where-Object {
            $_.name -eq $GroupName
        })

        if ($GroupExists.Count -eq 0) {

            Write-Host "Group does not exist: $GroupName" `
                -ForegroundColor Yellow

            Write-Host "Skipping group." -ForegroundColor Yellow

            $SkippedGroups += "$GroupName (group does not exist)"

            continue
        }

        if ($PSCmdlet.ShouldProcess(
                $Username,
                "Add user to JumpCloud group '$GroupName'"
            )) {

            Add-JCUserGroupMember `
                -GroupName $GroupName `
                -Username $Username

            $AssignedGroups += $GroupName

            Write-Host "User added to group: $GroupName" `
                -ForegroundColor Green
        }
    }
}

# ------------------------------------------------------------
# 5. Onboarding summary
# ------------------------------------------------------------

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " ONBOARDING COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "User      : $FirstName $LastName" -ForegroundColor Green
Write-Host "Username  : $Username" -ForegroundColor Green
Write-Host "Email     : $Email" -ForegroundColor Green
Write-Host "Department: $Department" -ForegroundColor Green
Write-Host "Job Title : $JobTitle" -ForegroundColor Green

Write-Host ""
Write-Host "Groups assigned:" -ForegroundColor Green

if ($AssignedGroups.Count -gt 0) {

    foreach ($GroupName in $AssignedGroups) {
        Write-Host "  - $GroupName"
    }
}
else {

    Write-Host "  - None"
}

Write-Host ""
Write-Host "Groups skipped:" -ForegroundColor Yellow

if ($SkippedGroups.Count -gt 0) {

    foreach ($GroupName in $SkippedGroups) {
        Write-Host "  - $GroupName"
    }
}
else {

    Write-Host "  - None"
}

Write-Host ""
Write-Host "User onboarding completed successfully." `
    -ForegroundColor Green
Write-Host ""
