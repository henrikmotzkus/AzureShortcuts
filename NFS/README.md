# Deploy a NFS Linux Server to Azure with cloud-init

This example deploys a Ubuntu 18 LTS to an existing VNET with an additional disk attached. Then CLOUD-INIT configures the disk, installs a NFS server and exports the disk as an NFS export.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhenrikmotzkus%2FAzureShortcuts%2Fmain%2FNFS%2Fazuredeploy.json)


##Sources: 

Cloud-init documentation: https://cloudinit.readthedocs.io/en/18.5/topics/examples.html#
Inserting custom script into Linux: https://docs.microsoft.com/en-us/azure/virtual-machines/custom-data
Another cloud scripting website: https://www.digitalocean.com/community/tutorials/an-introduction-to-cloud-config-scripting
Quickstart template for custom data: https://github.com/Azure/azure-quickstart-templates/blob/master/101-vm-customdata/azuredeploy.json#


##How cloud-init based disk setup works
Important to know are the different used directives in the yaml-file

**disk_setup** searches for the device that is connected to lun0. The Azure deployment script will deploy one additional data disk which will contain the NFS data

**fs_setup** formats the whole disk with ext4

**mounts will** mount that disk to the filesystem

**package_upgrade** updates the Ubuntu system after creation

**packages installs** the nfs server software from the standard repository

**write_files** creates a config file for the NFS server

**runcmd** does various steps after the deployment