if (!$Global:SubscriptionID)
{
Write-Warning -Message "You Have not Configured a SubscriptionID"
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
    $ERCS_SESSION = Enter-PSSession -ComputerName $Global:PrivilegedEndpoint -ConfigurationName PrivilegedEndpoint -Credential $Global:CloudAdminCreds
}
catch {
        write-host "could not login Cloudadmin  $($Global:Cloudadmin), maybe wrong pasword ? 
        please re-run ./admin/99_bootstrap.ps1"
        $Global:CloudAdminCreds = ""
        Break	
}
Exit-PSSession


Write-Host "You now have to log in with your Subscription Owner $Global:SubscriptionOwner"

$SubscriptionOwnerContext = Login-AzureRmAccount -Environment "AzureCloud"

Select-AzureRmSubscription -SubscriptionId $Global:SubscriptionID
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.AzureStack  

Add-AzsRegistration `
    -CloudAdminCredential $Global:CloudAdminCreds `
    -AzureSubscriptionId $SubscriptionOwnerContext.Subscription `
    -AzureDirectoryTenantName $SubscriptionOwnerContext.Tenant.TenantId `
    -PrivilegedEndpoint $Global:PrivilegedEndpoint  `
    -BillingModel Development 