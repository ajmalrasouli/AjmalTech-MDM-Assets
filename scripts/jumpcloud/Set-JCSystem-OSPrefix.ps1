#Requires -Version 7.0

<#
.SYNOPSIS
    Applies OS-based naming prefixes to JumpCloud systems.

.DESCRIPTION
    Retrieves systems from JumpCloud and applies the following naming
    convention:
      mac-     for macOS systems (osFamily: darwin)
      windows- for Windows systems (osFamily: windows)
      linux-   for Linux systems (osFamily: linux)

    Android and iOS/iPadOS devices are skipped.

    The script is idempotent: systems that already have their required
    prefix are left unchanged.

.PREREQUISITES
    - PowerShell 7+
    - JumpCloud PowerShell module (JumpCloud.PowerShell)
    - An authenticated Connect-JCOnline session

.NOTES
    This script makes live changes to JumpCloud device display names.
    Review the target organisation and the proposed changes before running.
#>

$ErrorActionPreference = "Stop"

# Retrieve the current inventory from JumpCloud.
$Systems = Get-JCSystem

foreach ($System in $Systems) {

    # Select the naming prefix based on the operating-system family.
    $Prefix = switch ($System.osFamily) {
        "darwin"  { "mac-"; break }
        "windows" { "windows-"; break }
        "linux"   { "linux-"; break }
        default   { $null }
    }

    # Leave unsupported OS families (Android and iOS/iPadOS) unchanged.
    if ([string]::IsNullOrWhiteSpace($Prefix)) {
        Write-Host "Skipped: $($System.displayName) ($($System.osFamily))"
        continue
    }

    # Do not add the prefix again if the device name already starts with it.
    if ($System.displayName -like "$Prefix*") {
        Write-Host "Already correct: $($System.displayName)"
        continue
    }

    $NewName = "$Prefix$($System.displayName)"

    Write-Host "Updating: $($System.displayName) -> $NewName"

    # Update the device display name in JumpCloud.
    Set-JCSystem `
        -SystemID $System._id `
        -displayName $NewName
}
