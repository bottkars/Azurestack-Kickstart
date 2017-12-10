$subscription = '8c21cadc-9e41-459e-bf4b-919aa2fad975'
Import-Module D:\AzureStack-Tools\Registration\RegisterWithAzure.psm1
$CloudAdmin = "AzureStack\Cloudadmin"
$CloudAdminPass = ConvertTo-SecureString "Passw0rd" -AsPlainText -Force
$CloudAdminCreds = New-Object System.Management.Automation.PSCredential($CloudAdmin, $CloudAdminPass)
$AzureContext = Get-AzureRmContext
Add-AzsRegistration `
    -CloudAdminCredential $CloudAdminCreds `
    -AzureSubscriptionId $AzureContext.Subscription.Id `
    -AzureDirectoryTenantName $AzureContext.Tenant.TenantId `
    -PrivilegedEndpoint AzS-ERCS01 `
    -BillingModel Development 