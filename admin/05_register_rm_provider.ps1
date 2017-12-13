if (!$Global:SubscriptioID)
{
Write-Warning -Message "You Have not Configured a SubscriptioID"
break
}
if (!$Global:Service_RM_Account.Context)
{
Write-Warning -Message "You aree not signed in to your Azure RM Environment as Serviceadmin. Please run .\admin\99_bootstrap.ps1"
break
}
Login-AzureRmAccount -EnvironmentName "AzureCloud" -credential $Global:ServiceAdminCreds
Select-AzureRmSubscription -SubscriptionId $Global:subscriptionID
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.AzureStack