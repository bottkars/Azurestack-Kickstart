$subscription = '90d4abb3-8c7b-48bb-bd16-63fd14bac8cb'
Login-AzureRmAccount -EnvironmentName "AzureCloud"
Select-AzureRmSubscription -SubscriptionId $subscription
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.AzureStack