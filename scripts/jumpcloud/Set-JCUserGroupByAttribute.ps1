#Requires -Version 7.0

<#
.SYNOPSIS
    Dynamically creates JumpCloud user groups from user attributes and
    assigns those groups to a resource.

.DESCRIPTION
    This script demonstrates attribute-based identity automation:

      1. Reads JumpCloud users.
      2. Evaluates user attributes such as Department, Location,
         EmployeeType and JobTitle.
      3. Creates user groups when they do not already exist.
      4. Adds matching users to the appropriate groups.
      5. Excludes users when an exclusion rule matches.
      6. Associates the user group with a JumpCloud resource.

    The script is idempotent. Existing groups, memberships and resource
    associations are not recreated.

    Use -WhatIf first. The default rules below are examples and should be
    changed to match your JumpCloud organisation.

.NOTES
    Requires:
      - PowerShell 7+
      - JumpCloud PowerShell module
      - Authenticated Connect-JCOnline session

    JumpCloud supports dynamic user groups based on attributes such as
    Department, Location, Employee Type, Job Title and custom attributes.
    This script demonstrates the same concept programmatically.
#>

[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------------------------------

# Resource that the generated user groups will be connected to.
# Supported TargetType values include:
# application, g_suite, ldap_server, office_365, radius_server, system_group
$ResourceType = "application"
$ResourceName = "AjmalTech-Engineering-App"

# Define attribute-based group rules.
#
# Match:
#   All listed conditions must match.
#
# Exclude:
#   If any listed exclusion condition matches, the user is not added.
#
# Add more rules to create additional attribute-based groups.
$GroupRules = @(
    @{
        GroupName = "AJT - Engineering - UK"
        Match = @{
            Department = "Engineering"
            Location   = "UK"
        }
        Exclude = @{
            EmployeeType = "Contractor"
        }
    },

    @{
        GroupName = "AJT - Finance - UK"
        Match = @{
            Department = "Finance"
            Location   = "UK"
        }
        Exclude = @{
            EmployeeType = "Contractor"
        }
    },

    @{
        GroupName = "AJT - IT - Admins"
        Match = @{
            Department = "IT"
            JobTitle   = "Administrator"
        }
        Exclude = @{
            EmployeeType = "Contractor"
        }
    }
)

# ---------------------------------------------------------------------------
# FUNCTIONS
# ---------------------------------------------------------------------------

function Test-UserAttributes {
    param(
        [Parameter(Mandatory)]
        $User,

        [Parameter(Mandatory)]
        [hashtable]$Conditions
    )

    foreach ($Condition in $Conditions.GetEnumerator()) {

        $AttributeName = $Condition.Key
        $ExpectedValue = [string]$Condition.Value
        $ActualValue = [string]$User.$AttributeName

        if ($ActualValue -ne $ExpectedValue) {
            return $false
        }
    }

    return $true
}

# ---------------------------------------------------------------------------
# GET CURRENT DATA
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " AJMALTECH - ATTRIBUTE BASED USER GROUPING" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

$Users = @(Get-JCUser)
$ExistingGroups = @(Get-JCUserGroup)

Write-Host "Users found: $($Users.Count)"
Write-Host "User groups found: $($ExistingGroups.Count)"
Write-Host ""

# ---------------------------------------------------------------------------
# PROCESS EACH RULE
# ---------------------------------------------------------------------------

foreach ($Rule in $GroupRules) {

    $GroupName = $Rule.GroupName

    Write-Host "----------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Group: $GroupName" -ForegroundColor Yellow

    # Find or create the target user group.
    $Group = $ExistingGroups | Where-Object { $_.name -eq $GroupName } | Select-Object -First 1

    if (-not $Group) {

        if ($PSCmdlet.ShouldProcess($GroupName, "Create JumpCloud user group")) {

            $Group = New-JCUserGroup -Name $GroupName
            Write-Host "Created group: $GroupName" -ForegroundColor Green
            $ExistingGroups += $Group
        }
        else {
            Write-Host "WhatIf: Would create group: $GroupName" -ForegroundColor Magenta
            continue
        }
    }
    else {
        Write-Host "Group already exists: $GroupName"
    }

    # Find users matching the required attributes.
    $MatchingUsers = foreach ($User in $Users) {

        if (-not (Test-UserAttributes -User $User -Conditions $Rule.Match)) {
            continue
        }

        # Exclude users matching any exclusion condition.
        $Excluded = $false

        foreach ($ExcludeCondition in $Rule.Exclude.GetEnumerator()) {

            $ActualValue = [string]$User.($ExcludeCondition.Key)
            $ExcludedValue = [string]$ExcludeCondition.Value

            if ($ActualValue -eq $ExcludedValue) {
                $Excluded = $true
                break
            }
        }

        if (-not $Excluded) {
            $User
        }
        else {
            Write-Host "Excluded: $($User.username)" -ForegroundColor DarkYellow
        }
    }

    Write-Host "Matching users: $($MatchingUsers.Count)"

    # Get current group membership.
    $CurrentMembers = @(Get-JCUserGroupMember -GroupName $GroupName)
    $CurrentUsernames = @($CurrentMembers | ForEach-Object { $_.Username })

    # Add matching users that are not already members.
    foreach ($User in $MatchingUsers) {

        if ($User.username -in $CurrentUsernames) {
            Write-Host "Already a member: $($User.username)"
            continue
        }

        if ($PSCmdlet.ShouldProcess($User.username, "Add to user group '$GroupName'")) {

            Add-JCUserGroupMember -GroupName $GroupName -Username $User.username
            Write-Host "Added: $($User.username)" -ForegroundColor Green
        }
    }

    # -----------------------------------------------------------------------
    # CONNECT THE USER GROUP TO THE RESOURCE
    # -----------------------------------------------------------------------

    $ExistingAssociation = Get-JCAssociation -Type user_group -Name $GroupName -TargetType $ResourceType -IncludeNames |
        Where-Object { $_.targetName -eq $ResourceName }

    if ($ExistingAssociation) {
        Write-Host "Resource already assigned: $ResourceName"
    }
    elseif ($PSCmdlet.ShouldProcess("$GroupName -> $ResourceName", "Assign user group to resource")) {

        Add-JCAssociation -Type user_group -Name $GroupName -TargetType $ResourceType -TargetName $ResourceName -Force
        Write-Host "Assigned group to resource: $ResourceName" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " ATTRIBUTE-BASED GROUPING COMPLETE" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
