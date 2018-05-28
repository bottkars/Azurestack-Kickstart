$ComputeQuota = New-AzsComputeQuota -Name best-compute `
 -Location local -VirtualMachineCount 5000 `
 -AvailabilitySetCount 20 -CoresLimit 100 -VmScaleSetCount 20

$NetworkQuota = New-AzsNetworkQuota -Name best-network `
 -Location local -PublicIpsPerSubscription 20 -VNetsPerSubscription 20 `
 -GatewaysPerSubscription 10 -ConnectionsPerSubscription 1000 -NicsPerSubscription 10000
$StorageQuota = New-AzsStorageQuota -Name best-storage -Location local `
 -NumberOfStorageAccounts 300 -CapacityInGB 50000 

## create a plan
$PCF_PLAN = New-AzsPlan -Name best-plan -DisplayName "Best-plan for pcf /cf" -ResourceGroupName "palns_and_quotas" -QuotaIds $StorageQuota.Id,$NetworkQuota.Id,$ComputeQuota.Id -ArmLocation local
$Offer = New-AzsOffer -Name best-offer -DisplayName "Offer for PCF / Cloud Foundry" -BasePlanIds $PCF_PLAN.Id -ArmLocation local -ResourceGroupName "pfc-offer-rg"
New-AzsTenantSubscription -DisplayName "Azure PCF Subscription" -Owner pcfuser@labbuildr.com -OfferId $Offer.Id 