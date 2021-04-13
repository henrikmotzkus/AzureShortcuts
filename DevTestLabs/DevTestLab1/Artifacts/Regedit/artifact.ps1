[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    [string] $Path,
    [Parameter(Mandatory = $true)]
    [string] $Name,
    [Parameter(Mandatory = $true)]
    [string] $Propertyname,
    [Parameter(Mandatory = $true)]
    [string] $Value

   
)


###################################################################################################
#
# PowerShell configurations
#

# NOTE: Because the $ErrorActionPreference is "Stop", this script will stop on first failure.
#       This is necessary to ensure we capture errors inside the try-catch-finally block.
$ErrorActionPreference = "Stop"

# Ensure we set the working directory to that of the script.
Push-Location $PSScriptRoot

###################################################################################################
#
# Handle all errors in this script.
#

trap
{
    # NOTE: This trap will handle all errors. There should be no need to use a catch below in this
    #       script, unless you want to ignore a specific error.
    $message = $error[0].Exception.Message
    if ($message)
    {
        Write-Host -Object "ERROR: $message" -ForegroundColor Red
    }
    
    # IMPORTANT NOTE: Throwing a terminating error (using $ErrorActionPreference = "Stop") still
    # returns exit code zero from the PowerShell script when using -File. The workaround is to
    # NOT use -File when calling this script and leverage the try-catch-finally block and return
    # a non-zero exit code from the catch block.
    Write-Host 'Artifact failed to apply.'
    exit -1
}

###################################################################################################
#
# Functions used in this script.
#

function New-RegKey{
    [CmdletBinding()]
    param
    (
        [string] $Path,
        [string] $Name,
        [string] $Propertyname,
        [string] $Value
    )

 
    New-Item -Path $Path -Name $Name
    $Fullpath = $Path + "\" + $Name
    New-ItemProperty -Path $Fullpath -Name $Propertyname -Value $Value

}
###################################################################################################
#
# Main execution block.
#

try
{
    if ($PSVersionTable.PSVersion.Major -lt 3)
    {
        throw "The current version of PowerShell is $($PSVersionTable.PSVersion.Major). Prior to running this artifact, ensure you have PowerShell 3 or higher installed."
    }

    Write-Host "Attempting to create RegKey"
    
    New-RegKey -Path $Path -Name $Name -Propertyname $Propertyname -Value $Value

    Write-Host "RegKey successfully created"
}
finally
{
    Pop-Location
}