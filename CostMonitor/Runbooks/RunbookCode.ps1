<#
    .DESCRIPTION
        An example runbook which gets all the ARM resources using the Run As Account (Service Principal)

    .NOTES
        AUTHOR: Azure Automation Team
        LASTEDIT: Mar 14, 2016
#>

Param(
 [string]$ResourceGroupName
 
)

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}


$today =  Get-Date -Format yyyy-MM-dd
$yesterday = ((Get-Date).AddDays(-1)).ToString("yyyy-MM-dd")


#Get-AzureRMConsumptionUsageDetail -StartDate $today -EndDate $today -resourcegroup $ResourceGroupName | ConvertTo-Json | Out-File today.json -Encoding "UTF8"
#Get-AzureRMConsumptionUsageDetail -StartDate $yesterday -EndDate $yesterday -resourcegroup $ResourceGroupName | ConvertTo-Json | Out-File yesterday.json -Encoding "UTF8"


#Set-AzureRMCurrentStorageAccount -ResourceGroupName "EDEKA_CostMonitor" -AccountName "edekacostexports"


#Set-AzureRMStorageBlobContent -File today.json -Container daily
#Set-AzureRMStorageBlobContent -File yesterday.json -Container daily

#Import your Credential object from the Automation Account
$sqldb = Get-AutomationPSCredential -Name "sqldb"
#Import the SQL Server Name from the Automation variable.
$sqlserver = Get-AutomationVariable -Name "sqlserver"
#Import the SQL DB from the Automation variable.
$database = Get-AutomationVariable -Name "database"

$sql1 = "drop table dbo.today;"
invoke-sqlcmd -ServerInstance $sqlserver -Database $database -Credential $sqldb -Query "$sql1" -Encrypt

$sql2 = "SELECT AccountName, 
AdditionalInfo, 
AdditionalProperties, 
BillableQuantity, 
BillingPeriodId, 
BillingPeriodName, 
ConsumedService, 
CostCenter, 
Currency, 
DepartmentName, 
Id, 
InstanceId, 
InstanceLocation,  
InstanceName ,  
InvoiceId ,  
InvoiceName , 
IsEstimated ,  
MeterDetails ,  
MeterId , 
Name ,  
PretaxCost, 
Product ,   
SubscriptionGuid, 
SubscriptionName ,  
Tags ,  
Type ,  
UsageEnd, 
UsageQuantity, 
UsageStart
  
 INTO dbo.today
 FROM OPENROWSET (BULK 'today.json', SINGLE_CLOB, DATA_SOURCE='COSTS') as j
 CROSS APPLY OPENJSON(BulkColumn)
 WITH(
	AccountName nvarchar(400),  
	AdditionalInfo nvarchar(400),  
	AdditionalProperties nvarchar(400),  
	BillableQuantity nvarchar(400),  
	BillingPeriodId nvarchar(400),  
	BillingPeriodName nvarchar(400),  
	ConsumedService nvarchar(400),  
	CostCenter nvarchar(400), 
	Currency nvarchar(400),  
	DepartmentName nvarchar(400), 
	Id nvarchar(400),  
	InstanceId nvarchar(400), 
	InstanceLocation nvarchar(400),  
	InstanceName nvarchar(400),  
	InvoiceId nvarchar(400),  
	InvoiceName nvarchar(400), 
	IsEstimated nvarchar(400),  
	MeterDetails nvarchar(400),  
	MeterId nvarchar(400), 
	Name nvarchar(400),  
	PretaxCost float, 
	Product nvarchar(400),   
	SubscriptionGuid nvarchar(400), 
	SubscriptionName nvarchar(400),  
	Tags nvarchar(400),  
	Type nvarchar(400),  
	UsageEnd nvarchar(400), 
	UsageQuantity nvarchar(400), 
	UsageStart nvarchar(400)
 ) AS k;"

 invoke-sqlcmd -ServerInstance "$sqlserver" -Database "$database" -Credential $sqldb -Query "$sql2" -Encrypt

$sql3 = "drop table dbo.yesterday;"

invoke-sqlcmd -ServerInstance "$sqlserver" -Database "$database" -Credential $sqldb -Query "$sql2" -Encrypt

$sql4 = "SELECT AccountName, 
AdditionalInfo, 
AdditionalProperties, 
BillableQuantity, 
BillingPeriodId, 
BillingPeriodName, 
ConsumedService, 
CostCenter, 
Currency, 
DepartmentName, 
Id, 
InstanceId, 
InstanceLocation,  
InstanceName ,  
InvoiceId ,  
InvoiceName , 
IsEstimated ,  
MeterDetails ,  
MeterId , 
Name ,  
PretaxCost, 
Product ,   
SubscriptionGuid, 
SubscriptionName ,  
Tags ,  
Type ,  
UsageEnd, 
UsageQuantity, 
UsageStart
  
 INTO dbo.yesterday
 FROM OPENROWSET (BULK 'yesterday.json', SINGLE_CLOB, DATA_SOURCE='COSTS') as j
 CROSS APPLY OPENJSON(BulkColumn)
 WITH(
	AccountName nvarchar(400),  
	AdditionalInfo nvarchar(400),  
	AdditionalProperties nvarchar(400),  
	BillableQuantity nvarchar(400),  
	BillingPeriodId nvarchar(400),  
	BillingPeriodName nvarchar(400),  
	ConsumedService nvarchar(400),  
	CostCenter nvarchar(400), 
	Currency nvarchar(400),  
	DepartmentName nvarchar(400), 
	Id nvarchar(400),  
	InstanceId nvarchar(400), 
	InstanceLocation nvarchar(400),  
	InstanceName nvarchar(400),  
	InvoiceId nvarchar(400),  
	InvoiceName nvarchar(400), 
	IsEstimated nvarchar(400),  
	MeterDetails nvarchar(400),  
	MeterId nvarchar(400), 
	Name nvarchar(400),  
	PretaxCost float, 
	Product nvarchar(400),   
	SubscriptionGuid nvarchar(400), 
	SubscriptionName nvarchar(400),  
	Tags nvarchar(400),  
	Type nvarchar(400),  
	UsageEnd nvarchar(400), 
	UsageQuantity nvarchar(400), 
	UsageStart nvarchar(400)
 ) AS k;"

 invoke-sqlcmd -ServerInstance "$sqlserver" -Database "$database" -Credential $sqldb -Query "$sql4" -Encrypt

$sql5 = "SELECT a.[InstanceId],a.[PretaxCost] as todaycosts,b.[PretaxCost] as yesterdaycosts, a.[PretaxCost]- b.[PretaxCost] as diff, a.[Product],a.[SubscriptionGuid]
  FROM [dbo].[today] as a, [dbo].[yesterday] as b 
  WHERE a.instanceid = b.instanceid and a.meterid = b.meterid and a.[pretaxcost] > b.[pretaxcost] and a.[pretaxcost] > 50
  order by diff desc;"

  invoke-sqlcmd -ServerInstance "$sqlserver" -Database "$database" -Credential $sqldb -Query "$sql5" -Encrypt

$result

