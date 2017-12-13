if (!$Global:SubscriptionID)
{
Write-Warning -Message "You Have not Configured a SubscriptioID"
break
}
if (!$Global:CloudAdminCreds)
{
Write-Warning -Message "You aree not signed in to your Azure RM Environment as CloudAdmin. Please run .\admin\99_bootstrap.ps1"
break
}
Import-Module D:\AzureStack-Tools\Registration\RegisterWithAzure.psm1
Write-Host "Testing ESRC Connection"
try {
    $ERCS_SESSION = Enter-PSSession -ComputerName $Global:ercs -ConfigurationName PrivilegedEndpoint -Credential $Global:CloudAdminCreds
}
catch {
        write-host "could not login Cloudadmin  $($Global:Cloudadmin), maybe wrong pasword ? 
        please re-run ./admin/99_bootstrap.ps1"
        $Global:CloudAdminCreds = ""
        Break	
}
$ERCS_SESSION | Exit-PSSession

Select-AzureRmSubscription -SubscriptionId $Global:SubscriptionID
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.AzureStack  


$AzureContext = Get-AzureRmContext
Add-AzsRegistration `
    -CloudAdminCredential $Global:CloudAdminCreds `
    -AzureSubscriptionId $AzureContext.Subscription `
    -AzureDirectoryTenantName $AzureContext.Tenant.TenantId `
    -PrivilegedEndpoint $Global:PrivilegedEndpoint  `
    -BillingModel Development 