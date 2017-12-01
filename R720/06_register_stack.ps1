$subscription = '8c21cadc-9e41-459e-bf4b-919aa2fad975'
Import-Module D:\AzureStack-Tools\Registration\RegisterWithAzure.psm1
$cred = Get-Credential -Message 'enter cloudadmin password' -UserName "azurestack\cloudadmin"

Add-AzsRegistration -CloudAdminCredential $cred -AzureDirectoryTenantName $TenantName  -AzureSubscriptionId $subscription -PrivilegedEndpoint 'azs-ercs01' -BillingModel Development