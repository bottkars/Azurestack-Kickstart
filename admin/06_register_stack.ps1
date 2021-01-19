[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-kickstart")]
param (
        [Parameter(Mandatory = $false)]
        [String] $ResourceGroupName = 'azurestack',
        [Parameter(Mandatory = $false)]
        [String] $ResourceGroupLocation = 'westcentralus',
        [Parameter(Mandatory = $false)]
        [String] $RegistrationName = 'azurestack'
)        
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if (!$myWindowsPrincipal.IsInRole($adminRole))
  {
  $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
  $newProcess.Arguments = "-noexit $PSScriptRoot/99_bootstrap.ps1;$PSScriptRoot/$($myinvocation.MyCommand) -ResourceGroupLocation $ResourceGroupLocation -ResourceGroupName $ResourceGroupName" 
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
Import-Module $Global:AZSTools_location\Registration\RegisterWithAzure.psm1
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
$SubscriptionOwnerContext = Login-AzAccount -Environment "AzureCloud" -SubscriptionId $Global:SubscriptionID
Write-Host -ForegroundColor White -NoNewline "[==>]Selecting $($SubscriptionOwnerContext.Context.Subscription) "
Select-AzSubscription -SubscriptionId $Global:SubscriptionID
Write-Host -ForegroundColor Green [Done]
Write-Host -ForegroundColor White -NoNewline "[==>]registering AzProvider"
Register-AzResourceProvider -ProviderNamespace Microsoft.AzureStack  
Write-Host -ForegroundColor Green [Done]
$Azcontext = Get-AzContext
Write-Host -ForegroundColor White "Registering Azure Stack with $($SubscriptionOwnerContext.Context.Tenant.TenantId)" -NoNewline
$AZSregistration = Set-AzsRegistration `
    -PrivilegedEndpointCredential $Global:CloudAdminCreds `
    -AzureContext $Azcontext `
    -PrivilegedEndpoint $Global:PrivilegedEndpoint `
    -BillingModel Development `
    -ResourceGroupLocation $ResourceGroupLocation `
    -ResourceGroupName $ResourceGroupName `
    -RegistrationName $RegistrationName `
    -MarketplaceSyndicationEnabled `
    -UsageReportingEnabled `
#    -AzureDirectoryTenantName $SubscriptionOwnerContext.Context.Tenant.TenantId `

    Write-Host -ForegroundColor Green [Done]
.$PSScriptRoot/99_bootstrap.ps1    
    