param (
[ValidatePattern("^[a-z][a-z0-9-]{1,61}[a-z0-9]$")]$sqlhost = $Global:SQLHost,
[securestring]$adminPassword = $Global:VMPassword, 
$adminUsername= $Global:SQLRPadmin
)

$templateuri = 'https://raw.githubusercontent.com/Azure/AzureStack-QuickStart-Templates/master/sql-2014-standalone/azuredeploy.json'

New-AzureRmResourceGroup -Name "RG_$sqlhost" -Location local 
New-AzureRmResourceGroupDeployment -Name "$($sqlhost)_deployment" `
-vmName $sqlhost -dnsNameForPublicIP $sqlhost `
-ResourceGroupName "RG_$sqlhost" `
-TemplateUri $templateuri `
-adminPassword  $Global:VMPassword  `
-adminUsername $Global:SQLRPadmin `
-windowsOSVersion "2016-Datacenter" `
-Mode Incremental -Verbose 