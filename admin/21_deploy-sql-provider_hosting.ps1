<#
Hosting Server Name: <SQL Server FQDN or IPv4 of an existing SQL server to be added as a SQL Adapter hosting server>
Port: <Optional parameter for SQL Server Port, default is 1433>
InstanceName: <Optional parameter for SQL Server Instance>
Total Space MB: <The total space in MB to be allocated for creation of databases on the hosting server>
Hosting Server SQL Login Name: <Name of a SQL login to be used for connecting to the SQL database engine on the hosting server using SQL authentication>
Hosting Server SQL Login Password: <Password for the given SQL login>
SKU Name: <Name of the SQL Adapter SKU to associate the hosting server to>
SKU MUST BE CREATED AFTERB SQL RP IS CREATED !!! TAKES UP To 1 Hr to appear
#>
param (
[ValidatePattern("^[a-z][a-z0-9-]{1,61}[a-z0-9]$")]$sqlhost = $Global:SQLhost,
[securestring]$SQLRPPassword = $Global:VMPassword,
$RG= "rg_sql_hosting"
)
    
$templateuri = 'https://raw.githubusercontent.com/bottkars/AzureStack-QuickStart-Templates/patch-3/101-sqladapter-add-hosting-server/azuredeploy.json'

New-AzureRmResourceGroup -Name $RG -Location local 
New-AzureRmResourceGroupDeployment -Name "$($RG)_DEPLOY" -ResourceGroupName $RG `
    -TemplateUri $templateuri `
    -HostingServerName "$($sqlhost).local.cloudapp.azurestack.external" `
-hostingServerSQLLoginName sa `
-hostingServerSQLLoginPassword $SQLRPPassword `
-Mode Incremental `
-totalSpaceMB 102400 `
-skuName SQL2014