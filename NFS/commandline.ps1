# Powershell script to deploy this script via AZ-module
Connect-AzAccount
$ResourceGroupName = "NFS"
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateParameterUri "https://raw.githubusercontent.com/henrikmotzkus/AzureShortcuts/main/NFS/azuredeploy.json" -TemplateUri "https://github.com/henrikmotzkus/AzureShortcuts/blob/main/NFS/azuredeploy.parameters.json"