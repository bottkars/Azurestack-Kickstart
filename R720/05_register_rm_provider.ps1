$subscription = 'ff6baa2c-f460-4950-9ede-d2b012ee10a4' 
Login-AzureRmAccount -EnvironmentName "AzureCloud" -AccountId "Karsten.Bott@emc.com"
Select-AzureRmSubscription -SubscriptionId $subscription
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.AzureStack