# ^[a-z][a-z0-9-]{1,61}[a-z0-9]$
param(
[ValidatePattern("^[a-z][a-z0-9-]{1,61}[a-z0-9]$")]$mysqlhost = $Global:mysqlhost,
$adminusername = $Global:MySQLRPadmin,
[securestring]$adminpassword = $Global:VMPassword
)
,
$RG = "rg_$mysqlhost"


New-AzureRmResourceGroup -Name $RG -Location local 

New-AzureRmResourceGroupDeployment -Name "$($mysqlhost)_deployment" -ResourceGroupName $RG `
    -vmName $mysqlhost `
    -TemplateUri https://raw.githubusercontent.com/bottkars/AzureStack-QuickStart-Templates/patch-2/mysql-standalone-server-windows/azuredeploy.json `
    -adminPassword $adminpassword `
    -adminUsername $adminusername `
    -windowsOSVersion "2016-Datacenter" `
    -Mode Incremental `
    -vmSize Standard_A4 `
    -Verbose

    
