Connect-AzAccount

$ResourceGroupName = "ECE_NFS"



New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateUri https://raw.githubusercontent.com/henrikmotzkus/NFS/main/template.json



New-AzResourceGroupDeployment -ResourceGroupName ece_nfs -TemplateParameterUri https://raw.githubusercontent.com/henrikmotzkus/NFS/main/azuredeploy.parameters.json -TemplateUri https://raw.githubusercontent.com/henrikmotzkus/NFS/main/azuredeploy.json