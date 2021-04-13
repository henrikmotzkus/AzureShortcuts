<#
    .DESCRIPTION
        This script coordinates the setup

    .NOTES
        AUTHOR: Azure Automation Team
        LASTEDIT: Mar 14, 2016
#>
Param(
 [Parameter(Mandatory=$true)]
 [string]$ResourceGroupName
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
    # Write-Host 'Error.'
    exit -1
}

# Connecting to the Azure environment
Connect-AzAccount -Tenant 72f988bf-86f1-41af-91ab-2d7cd011db47 -Subscription "2abc2ec1-2238-430d-bf52-40cb7dc8b652"


try {

    # Find out own IP internet adress for firewalling
    $IP = convertto-securestring -string ((Invoke-WebRequest ifconfig.me/ip).Content.Trim()).ToString() -AsPlainText


    # The source of the runbook that is populated to the automation account 
    # $Runbookscripturi = "https://dev.azure.com/hemotzku/fe51df6a-8bc3-4997-821e-7acf9d7440d1/_apis/git/repositories/36b993c5-15ba-4161-b865-23d266640436/items?path=%2FRunbookCode.ps1&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=octetStream&api-version=5.0&download=true"

    New-AzResourceGroup -Name $ResourceGroupName -Location "westeurope"

    # Get the credentials for the SQL database
    $creds = Get-Credential

    # The name of the dployment
    $deploymentname = "edekacosts"

    # Deploys the neccessary services to the resource group 
    New-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile "./azuredeploy.json" `
    -TemplateParameterFile "./azureDeploy.parameters.json" `
    -sqlpassword $creds.Password `
    -name $deploymentname `
    -sqladminuser $creds.UserName `
    -IP $IP

    # Gets the name of the new storage account
    $storageaccountname = (Get-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -Name $deploymentname ).Outputs.storageaccountname.value
                                    
    $sqlservername = (Get-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -Name $deploymentname ).Outputs.sqlservername.value
    
    $sqldbname = (Get-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -Name $deploymentname ).Outputs.sqldbname.value

    # Gets a context to the new stprage account
    $context = (Get-AzStorageAccount `
    -ResourceGroupName $ResourceGroupName `
    -AccountName $storageaccountname).context

    # Creates a SAS token for the stprage account
    $SAS = New-AzStorageAccountSASToken `
    -Context $context `
    -Service Blob,File,Table,Queue `
    -ResourceType Service,Container,Object `
    -Permission racwdlup

    # Creates a BLOB container and gets the absolute URI
    $containeruri = (New-AzStorageContainer `
    -Name "daily" `
    -Context $context).CloudBlobContainer.Uri.AbsoluteUri


    # Configures the existing database

    $sqlservername = $sqlservername+".database.windows.net"

    .\SetupDatabase.ps1 `
    -sqlserver $sqlservername `
    -database $sqldbname `
    -creds $creds `
    -SAS $SAS `
    -location $containeruri

    $automationaccountname = (Get-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -Name $deploymentname ).Outputs.automationaccountname.value

    # Configures the automation account
    Import-AzAutomationRunbook `
    -Name "dailycosts" `
    -Path ".\Runbooks\RunBookCode.ps1" `
    -Type PowerShell `
    -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $automationaccountname `
    –Force

    #Publish the runbook
    Publish-AzAutomationRunbook `
    -AutomationAccountName $automationaccountname `
    -ResourceGroupName $ResourceGroupName `
    -Name "dailycosts"

    # Create a schedule

    $StartTime = (Get-Date "13:00:00").AddDays(1)


    New-AzAutomationSchedule `
    –AutomationAccountName $automationaccountname `
    –Name "dailycosts" `
    -StartTime $StartTime `
    -HourInterval 24  `
    -ResourceGroupName $ResourceGroupName


} finally {

}
