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
# This function is used to join the machine to a domain

function Join-Domain 
{
    [CmdletBinding()]
    param
    (
        [string] $DomainName,
        [string] $UserName,
        [securestring] $Password,
        [string] $OUPath
    )

    # Checks if cmachine is already in a domain
    if ((Get-WmiObject Win32_ComputerSystem).Domain -eq $DomainName)
    {
        # Writ out error message
        Write-Host "Computer $($Env:COMPUTERNAME) is already joined to domain $DomainName."
    }
    else
    {
        # creating a new credential object for joining
        $credential = New-Object System.Management.Automation.PSCredential($UserName, $Password)
        
        if ($OUPath)
        {
            # when OU path provided joining to the specified OU
            [Microsoft.PowerShell.Commands.ComputerChangeInfo]$computerChangeInfo = Add-Computer -DomainName $DomainName -Credential $credential -OUPath $OUPath -Force -PassThru
        }
        else
        {
            # When OU not provided not joining to a specific OU
            [Microsoft.PowerShell.Commands.ComputerChangeInfo]$computerChangeInfo = Add-Computer -DomainName $DomainName -Credential $credential -Force -PassThru
        }
        
        if (-not $computerChangeInfo.HasSucceeded)
        {
            # throw error and go to trap 
            throw "Failed to join computer $($Env:COMPUTERNAME) to domain $DomainName."
        }
        
        # write out success message
        Write-Host "Computer $($Env:COMPUTERNAME) successfully joined domain $DomainName."
    }
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

    # Write out that joining beginns
    Write-Host "Attempting to join computer $($Env:COMPUTERNAME) to domain $DomainToJoin."
    
    # specified domain to joid. Importand is that the VNET where the VM will spinned up needs an attached DNS server.
    $DomainToJoin = "bdfgroup.net"

    # Username to join. Importand is to have the domain specified "DOMAIN\username"
    $DomainAdminUsername = "BDFGROUP\ADM1Thompson"

    # For joining we need the domain administrator password. THe password is stored in an Azure key vault. 
    # Here we re getting an access token to access the kay vault
    # The DevTest lab need a managed identity with sufficien acces rights configured 
    $response = Invoke-WebRequest -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -Method GET -Headers @{Metadata="true"} -UseBasicParsing

    # Converting the repsonse from json to a powershell object
    $content = $response.Content | ConvertFrom-Json
    
    # Getting the access token property from the object
    $KeyVaultToken = $content.access_token

    # Getting the password from the key vault 
    $secret = (Invoke-WebRequest -Uri https://domainjoinhenrik.vault.azure.net/secrets/adminlocal?api-version=2016-10-01 -Method GET -Headers @{Authorization="Bearer $KeyVaultToken"} -UseBasicParsing).content | convertfrom-json

    # extracting the password and store it to a secure string
    [securestring] $securesecret = convertto-securestring -string $secret.value -AsPlainText -Force

    # OU path specification
    $OUPath = "OU=Standard-Servers,OU=Servers,OU=BSS,DC=Global,DC=BDFGroup,DC=net"

    # call the domain join function
    Join-Domain -DomainName $DomainToJoin -UserName $DomainAdminUsername -Password $securesecret -OUPath $OUPath

    # write out success message
    Write-Host 'Computer joined successfully.'
}
finally
{
    Pop-Location
}