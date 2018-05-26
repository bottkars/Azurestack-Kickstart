# ^[a-z][a-z0-9-]{1,61}[a-z0-9]$
param(
[ValidatePattern("^[a-z][a-z0-9-]{1,61}[a-z0-9]$")]$mysqlhost = $Global:mysqlhost,
$adminusername = $Global:MySQLRPadmin,
[securestring]$adminpassword = $Global:VMPassword
)
if (!$Global:SubscriptionID)
    {
    Write-Warning -Message "You Have not Configured a SubscriptionID, did you run 99_bootstrap.ps1 ?"
    break
}

if ($Subscription = Get-AzureRmSubscription -SubscriptionName "Consumption Subscription")
  {
  Write-Host "Setting Environment to Metering Subscription"
  Select-AzureRmSubscription -Subscription $Subscription  
  }
$RG = "rg_$mysqlhost"
$templateuri = 'https://raw.githubusercontent.com/Azure/AzureStack-QuickStart-Templates/master/mysql-standalone-server-windows/azuredeploy.json'
try {
    Get-AzureRmVMImage -Location $Global:AZS_location -PublisherName MicrosoftWindowsServer `
    -Offer WindowsServer -Skus 2016-Datacenter `
    -ErrorAction Stop
}
catch {
     Write-Warning "No 2016-Datacenter found in $($Global:AZS_location), please upload a 2016-Datacenter Image first ( use 11_deploy_windows_marketplace_image.ps1 )"
     Break
    }

New-AzureRmResourceGroup -Name $RG -Location local 

New-AzureRmResourceGroupDeployment -Name "$($mysqlhost)_deployment" -ResourceGroupName $RG `
    -vmName $mysqlhost `
    -TemplateUri $templateuri `
    -adminPassword $adminpassword `
    -adminUsername $adminusername `
    -windowsOSVersion "2016-Datacenter" `
    -Mode Incremental `
    -vmSize Standard_A4 `
    -Verbose

    
