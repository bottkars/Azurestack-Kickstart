$subscription = '90d4abb3-8c7b-48bb-bd16-63fd14bac8cb'
Import-Module C:\AzureStack-Tools\Registration\RegisterWithAzure.psm1
$cred = Get-Credential -Message 'enter cloudadmin password' -UserName "azurestack\cloudadmin"

Add-AzsRegistration -CloudAdminCredential $cred -AzureDirectoryTenantName $TenantName  -AzureSubscriptionId $subscription -PrivilegedEndpoint 'azs-ercs01' -BillingModel Development