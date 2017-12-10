$subscription = '8c21cadc-9e41-459e-bf4b-919aa2fad975' 
Login-AzureRmAccount -EnvironmentName "AzureCloud"
Select-AzureRmSubscription -SubscriptionId $subscription
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.AzureStack