[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-kickstart")]
param (
$adminARMEndpoint = $global:ArmEndpoint,
$azureStackDirectoryTenant = $global:TenantName,
[Parameter(ParameterSetName = "1", Mandatory = $true)]$guestDirectoryTenantName,
$ResourceGroupName = "system.local",
$tenantARMEndpoint = "https://management.local.azurestack.external",
$AutomationCredential = $global:ServiceAdminCreds
)
Import-Module "$($Global:AZSTools_location)\Connect\AzureStack.Connect.psm1"
Import-Module  "$($Global:AZSTools_location)\Identity\AzureStack.Identity.psm1"
Register-AzSGuestDirectoryTenant -AdminResourceManagerEndpoint $adminARMEndpoint `
 -DirectoryTenantName $azureStackDirectoryTenant `
 -GuestDirectoryTenantName $guestDirectoryTenantName `
 -Location "local" `
 -ResourceGroupName $ResourceGroupName -AutomationCredential $AutomationCredential

Register-AzSWithMyDirectoryTenant `
 -TenantResourceManagerEndpoint $tenantARMEndpoint `
 -DirectoryTenantName $guestDirectoryTenantName `
 