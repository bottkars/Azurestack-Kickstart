param (
[ValidatePattern("^[a-z][a-z0-9-]{1,61}[a-z0-9]$")]$sql_hostname = 'sqlhost1',
[securestring]$adminPassword = $Global:VMPassword, 
$adminUsername= $Global:SQLRPadmin
)

$templateuri = 'https://raw.githubusercontent.com/Azure/AzureStack-QuickStart-Templates/master/sql-2014-standalone/azuredeploy.json'
$vmLocalAdminCreds = New-Object System.Management.Automation.PSCredential ("sqlrpadmin", $vmLocalAdminPass) 

New-AzureRmResourceGroup -Name "RG_$sql_hostname" -Location local 
New-AzureRmResourceGroupDeployment -Name "$($sql_hostname)_deployment" `
-vmName $sql_hostname -dnsNameForPublicIP $sql_hostname `
-ResourceGroupName "RG_$sql_hostname" `
-TemplateUri $templateuri `
-adminPassword  $Global:VMPassword  `
-adminUsername $Global:SQLRPadmin `
-windowsOSVersion "2016-Datacenter" `
-Mode Incremental -Verbose 