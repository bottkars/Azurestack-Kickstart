#requires -module AzureStack.ServiceAdmin
#requires -module AzureStack.ComputeAdmin
#requires -module AzureRM.AzureStackStorage

$name = "Base"
$rg_name = "plans_and_offers"
$ComputeQuota = New-AzsComputeQuota -Name "$($name)_compute" -Location local # -VirtualMachineCount 5000
$NetworkQuota = New-AzsNetworkQuota -Name "$($name)_network" -Location local # -PublicIpsPerSubscription 20 -VNetsPerSubscription 20 -GatewaysPerSubscription 10 -ConnectionsPerSubscription 1000 -NicsPerSubscription 10000
$StorageQuota = New-AzsStorageQuota -Name "$($name)_storage" -Location local -NumberOfStorageAccounts 10 -CapacityInGB 500 -SkipCertificateValidation
## create a plan
$PLAN = New-AzsPlan -Name "$($name)_plan" -DisplayName "$name Plan" -ResourceGroupName $rg_name -QuotaIds $StorageQuota.Id,$NetworkQuota.Id,$ComputeQuota.Id -ArmLocation local
$Offer = New-AzsOffer -Name "$($name)_offer" -DisplayName "$name Offer" -State Public -BasePlanIds $PLAN.Id -ArmLocation local -ResourceGroupName $rg_name
New-AzsTenantSubscription -DisplayName "$name Subscription" -Owner "Azurestack Admin" -OfferId $Offer.Id 
