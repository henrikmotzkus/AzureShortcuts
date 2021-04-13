$ResourceGroupName = "ECE_NFS"



New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateUri https://raw.githubusercontent.com/henrikmotzkus/NFS/main/template.json