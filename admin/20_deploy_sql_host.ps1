param (
    [ValidatePattern("^[a-z][a-z0-9-]{1,61}[a-z0-9]$")]$sqlhost = $Global:SQLHost,
    [securestring]$adminPassword = $Global:VMPassword, 
    $adminUsername = $Global:SQLRPadmin
)
$templateuri = 'https://raw.githubusercontent.com/Azure/AzureStack-QuickStart-Templates/master/sql-2014-standalone/azuredeploy.json'
# we need an Server 2016 Image , so let´s check
if (!$Global:SubscriptionID)
{
Write-Warning -Message "You Have not Configured a SubscriptionID, did you run 99_bootstrap.ps1 ?"
break
}
try {
    Get-AzureRmVMImage -Location $Global:AZS_location -PublisherName MicrosoftWindowsServer `
        -Offer WindowsServer -Skus 2016-Datacenter `
        -ErrorAction Stop
}
catch {
    Write-Warning "No 2016-Datacenter found in $($Global:AZS_location), please upload a 2016-Datacenter Image first ( use 11_deploy_windows_marketplace_image.ps1 )"
    Break
}
if ($Subscription = Get-AzureRmSubscription -SubscriptionName "Consumption Subscription")
  {
  Write-Host "Setting Environment to Metering Subscription"
  Select-AzureRmSubscription -Subscription $Subscription  
  }
Get-AzureRmVMImage -Location $Global:AZS_location -PublisherName MicrosoftWindowsServer `
    -Offer WindowsServer -Skus 2016-Datacenter `
    -ErrorAction Stop

New-AzureRmResourceGroup -Name "RG_$sqlhost" -Location local 
New-AzureRmResourceGroupDeployment -Name "$($sqlhost)_deployment" `
    -vmName $sqlhost -dnsNameForPublicIP $sqlhost `
    -ResourceGroupName "RG_$sqlhost" `
    -TemplateUri $templateuri `
    -adminPassword  $Global:VMPassword  `
    -adminUsername $Global:SQLRPadmin `
    -windowsOSVersion "2016-Datacenter" `
    -Mode Incremental -Verbose 