### Prepare PCF Quotas, Plans and Offers
$TenantName = "karstenbottemc.onmicrosoft.com"
# run from your azurestack-tools dir, see msft getting started
Install-Module -Name AzureRm.BootStrapper -Force

Import-Module .\serviceAdmin\AzureStack.ServiceAdmin.psm1
Import-Module .\Connect\AzureStack.Connect.psm1
### requires install-module AzureRM.AzureStackStorage

Import-Module AzureRM.AzureStackStorage



# For Azure Stack development kit, this value is set to https://adminmanagement.local.azurestack.external. To get this value for Azure Stack integrated systems, contact your service provider.
$ArmEndpoint = "https://adminmanagement.local.azurestack.external"

# For Azure Stack development kit, this value is adminvault.local.azurestack.external 
$KeyvaultDnsSuffix = “adminvault.local.azurestack.externa”

# Register an AzureRM environment that targets your Azure Stack instance
Add-AzureRMEnvironment -Name "AzureStackAdmin" -ArmEndpoint $ArmEndpoint

$TenantID = Get-AzsDirectoryTenantId -AADTenantName $TenantName -EnvironmentName "AzureStackAdmin"

Login-AzureRmAccount -EnvironmentName "AzureStackAdmin" -TenantId $TenantID
$ComputeQuota = New-AzsComputeQuota -Name best-compute -Location local -VirtualMachineCount 5000
$NetworkQuota = New-AzsNetworkQuota -Name best-network -Location local -PublicIpsPerSubscription 20 -VNetsPerSubscription 20 -GatewaysPerSubscription 10 -ConnectionsPerSubscription 1000 -NicsPerSubscription 10000
$StorageQuota = New-AzsStorageQuota -Name best-storage -Location local -NumberOfStorageAccounts 300 -CapacityInGB 50000 -SkipCertificateValidation
## create a plan
$PCF_PLAN = New-AzsPlan -Name best-plan -DisplayName "best-plan for pcf" -ResourceGroupName "pcf-plan-rg" -QuotaIds $StorageQuota.Id,$NetworkQuota.Id,$ComputeQuota.Id -ArmLocation local
$Offer = New-AzsOffer -Name best-offer -DisplayName "Offer for PCF" -State Public -BasePlanIds $PCF_PLAN.Id -ArmLocation local -ResourceGroupName "pfc-offer-rg"
New-AzsTenantSubscription -DisplayName "Azure PCF Subscription" -Owner "Karsten Bott" -OfferId $Offer.Id 



set-location  C:\azure-stack-poc\1.10.3
. .\addPSFunctions.ps1
bootstrapPowershell -arm $ArmEndpoint

$opsmanager_uri  = "https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-1.10.3.vhd"
Start-BitsTransfer -Source $opsmanager_uri -Destination C:\Temp





