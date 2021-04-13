# Variables
$azureSubscriptionId = "2abc2ec1-2238-430d-bf52-40cb7dc8b652"
$resourceGroup = "ARMvsTerraform_State"
$location = "westeurope"
$random = -join ((0..9) | Get-Random -Count 5 | % {$_})
$accountName = "kopicloudtfstate" + $random
$containerName = "tfstate"
# Set Default Subscription
Select-AzSubscription -SubscriptionId $azureSubscriptionId
# Create Resource Group
New-AzResourceGroup -Name $resourceGroup -Location $location -Force
# Create Storage Account
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroup `
  -Name $accountName `
  -Location $location `
  -SkuName Standard_RAGRS `
  -Kind StorageV2 
    
# Get Storage Account Key
$storageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroup `
  -Name $accountName).Value[0]
# Create Storage Container
$ctx = $storageAccount.Context
$container = New-AzStorageContainer -Name $containerName `
  -Context $ctx -Permission blob
# Results
Write-Host 
Write-Host ("Storage Account Name: " + $accountName)
Write-Host ("Container Name: " + $container.Name)
Write-Host ("Access Key: " + $storageKey)