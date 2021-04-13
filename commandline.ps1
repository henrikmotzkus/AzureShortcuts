$ResourceGroupName = "ECE_NFS"


New-AzResourceGroup -Name <re



New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateUri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-vm-customdata/azuredeploy.json