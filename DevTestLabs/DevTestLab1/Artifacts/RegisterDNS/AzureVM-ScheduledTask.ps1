# --------------------------------------------------------------------------------------------------------------
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED 
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
#
#  Title         : Configure NIC to ensure PTR records are created in DNS (also added ipconfig /regiserdns)
#  Programmed by : Denis Rougeau
#  Date          : April 2015
#
# --------------------------------------------------------------------------------------------------------------
# Description
# ------------
# This script automate the process of configuring the NIC adapter to ensure PTR records are registered in DNS for
# the Azure VM.  The application has dependencies on IP to Name resolution, therefore DNS reverse lookup is necessary
#
# *** A REBOOT is necessary for the change to take effect
# --------------------------------------------------------------------------------------------------------------

 
$blnFullDNSRegistrationEnabled = $true
$blnDomainDNSRegistrationEnabled = $true
 
$NICs = Get-WMIobject -query "SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True"

 
ForEach ($NIC in $NICs)
{
  $Result = $NIC.SetDynamicDNSRegistration($blnFullDNSRegistrationEnabled, $blnDomainDNSRegistrationEnabled)
} 

ipconfig /registerdns
