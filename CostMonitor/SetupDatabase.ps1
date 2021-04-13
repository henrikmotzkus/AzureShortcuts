<#
    .DESCRIPTION
        Setup the database in order to import JSON Data from an Azure Blog storage. DEMO.

    .NOTES
        AUTHOR: Henrik Motzkus
        LASTEDIT: 19.01.2021
#>
Param(
 [string]$sqlserver,
 [string]$database,
 [pscredential]$creds,
 [string]$location,
 [string]$SAS
)

# Create a master password in order to create credentials
$sql1 = "CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Password123!';"
invoke-sqlcmd -ServerInstance $sqlserver -Database $database -Credential $creds -Query "$sql1" -Encrypt

# Create credentials in order to access to Azure blob storage
$sql2 = "CREATE DATABASE SCOPED CREDENTIAL CostMonitor WITH IDENTITY = 'SHARED ACCESS SIGNATURE', SECRET = '"+$SAS+"';"
invoke-sqlcmd -ServerInstance $sqlserver -Database $database -Credential $creds -Query "$sql2" -Encrypt

# Create external a data source
$sql3 = "CREATE EXTERNAL DATA SOURCE Costs WITH ( LOCATION = '"+$location+"' , CREDENTIAL = CostMonitor , TYPE = BLOB_STORAGE );"
invoke-sqlcmd -ServerInstance $sqlserver -Database $database -Credential $creds -Query "$sql3" -Encrypt



