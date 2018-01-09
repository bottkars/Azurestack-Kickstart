$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if (!$myWindowsPrincipal.IsInRole($adminRole))
  {
  $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
  $newProcess.Arguments = "-noexit $PSScriptRoot/99_bootstrap.ps1;$PSScriptRoot/$($myinvocation.MyCommand)" 
  Write-Host $newProcess.Arguments
  $newProcess.Verb = "runas"
  [System.Diagnostics.Process]::Start($newProcess) 
  exit
  }
if (!$Global:SubscriptionID)
  {
  Write-Warning -Message "You Have not Configured a SubscriptionID, did you run 99_bootstrap.ps1 ?"
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
        Break	0
}
Exit-PSSession

Write-Host -ForegroundColor  Yellow "You now have to log in with your Subscription Owner $Global:SubscriptionOwner"
Pause
$SubscriptionOwnerContext = Login-AzureRmAccount -Environment "AzureCloud"
Write-Host -ForegroundColor White -NoNewline "[==>]Selecting $($SubscriptionOwnerContext.Context.Subscription) "
Select-AzureRmSubscription -SubscriptionId $Global:SubscriptionID
Write-Host -ForegroundColor Green [Done]
Write-Host -ForegroundColor White -NoNewline "[==>]registering AzureRMProvider"
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.AzureStack  
Write-Host -ForegroundColor Green [Done]
Write-Host -ForegroundColor White "Registering Azure Stack with $($SubscriptionOwnerContext.Context.Tenant.TenantId)" -NoNewline
$AZSregistration = Add-AzsRegistration `
    -CloudAdminCredential $Global:CloudAdminCreds `
    -AzureSubscriptionId $SubscriptionOwnerContext.Context.Subscription `
    -AzureDirectoryTenantName $SubscriptionOwnerContext.Context.Tenant.TenantId `
    -PrivilegedEndpoint $Global:PrivilegedEndpoint  `
    -BillingModel Development

    Write-Host -ForegroundColor Green [Done]
    