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


# Function to create a new daily task 
function New-DNSRegisterTask
{
    [CmdletBinding()]
    param
    (
        [string] $Path,
        [string] $Filename
    )


    # Create directory if not exists
    New-Item -ItemType Directory -Force -Path $Path

    # Copy file to VM standard path
    Copy-Item $Filename -Destination $Path

     # Checking on existance
     if (-not (Test-Path -Path $Path$Filename))
     {
         # Throw message and go to trap 
         throw "Failed to copy file $Filename"
     }


    # Sets scheduled task to run C:\Setup\AzureVM-ScheduledTask.ps1 daily at Noon
    $trigger = New-ScheduledTaskTrigger -At 12pm -Daily
    $action = New-ScheduledTaskAction "powershell.exe" -Argument "-File $Path$Filename"
    Register-ScheduledTask -TaskName "AzureVM-ScheduledTask" -Trigger $trigger -User "System" -Action $action

}


###################################################################################################
#
# Main execution block.
#

try
{
    
    if ($PSVersionTable.PSVersion.Major -lt 3)
    {
        # check if powershell 3 and higher is installed otherwise throw an error and go to trap 
        throw "The current version of PowerShell is $($PSVersionTable.PSVersion.Major). Prior to running this artifact, ensure you have PowerShell 3 or higher installed."
    }

    # Write out message 
    Write-Host "Attempting to create daily task"

    # Download script from Azure DevOps repo
    $Path = "C:\Setup\"
    $Filename = "AzureVM-ScheduledTask.ps1"
    
    # Create Task
    New-DNSRegisterTask -Path $Path -Filename $Filename

    # Write out success message
    Write-Host "Task successfully created"
}
finally
{
    Pop-Location
}