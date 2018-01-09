param (
[ValidatePattern("^[a-z][a-z0-9-]{1,61}[a-z0-9]$")]$mysqlhost = $Global:mysqlhost,
[securestring]$MySQLRPPassword = $Global:VMPassword,
[securestring]$PfxPass = $Global:VMPassword,
$MySQLRPadmin = $Global:MySQLRPAdmin,
$RG = "rg_MySQLHostingserver",
$skuName = "mysql57"
)
if (!$Global:SubscriptionID)
    {
    Write-Warning -Message "You Have not Configured a SubscriptionID, did you run 99_bootstrap.ps1 ?"
    break
}
$fqdn = "$mysqlhost.local.cloudapp.azurestack.external"


New-AzureRmResourceGroup -Name $RG -Location local 

New-AzureRmResourceGroupDeployment -Name MySQLHostingserver_Deploy -ResourceGroupName $RG `
    -TemplateUri https://raw.githubusercontent.com/bottkars/AzureStack-QuickStart-Templates/patch-1/101-mysqladapter-add-hosting-server/azuredeploy.json `
    -HostingServerName $fqdn `
-password $MySQLRPPassword `
-username $MySQLRPadmin `
-Mode Incremental `
-totalSpaceMB 102400 `
-skuName $skuName