param(
  [Parameter(ParameterSetName = "1", Mandatory = $true, Position = 1)][ValidateSet(
'Microsoft.AzureBridge.Admin',
'Microsoft.Backup.Admin',
'Microsoft.Commerce.Providers',
'Microsoft.Compute',
'Microsoft.Compute.Admin',
'Microsoft.Fabric.Admin',
'Microsoft.Gallery.Providers',
'Microsoft.InfrastructureInsights.Admin',
'Microsoft.InfrastructureInsights.Providers',
'Microsoft.Insights',
'Microsoft.Insights.Providers',
'Microsoft.KeyVault',
'Microsoft.KeyVault.Admin',
'Microsoft.Network',
'Microsoft.Network.Admin',
'Microsoft.Storage',
'Microsoft.Storage.Admin',
'Microsoft.Storage.Admin',
'Microsoft.Subscriptions.Admin',
'Microsoft.Subscriptions.Providers',
'Microsoft.Update.Admin'
  )]$providerNamespace

)

Get-AzureRmResourceProvider | `
  Select ProviderNamespace -Expand ResourceTypes | `
  Select * -Expand ApiVersions | `
  Select ProviderNamespace, ResourceTypeName, @{Name='ApiVersion'; Expression={$_}} | `
  where-Object {$_.ProviderNamespace -like $providerNamespace}