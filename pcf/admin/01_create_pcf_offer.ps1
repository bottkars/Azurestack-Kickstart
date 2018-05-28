$rg_name = "plans_and_offers"
if (!($RG = Get-AzureRmResourceGroup -Name $rg_name -Location local))
    {
    Write-Host -ForegroundColor White -NoNewline "Creating RG $rg_name"        
    $TG = New-AzureRmResourceGroup -Name $rg_name -Location local
    Write-Host -ForegroundColor Green [Done]
    }


$ComputeQuota = New-AzsComputeQuota -Name best-compute `
 -Location local -VirtualMachineCount 5000 `
 -AvailabilitySetCount 20 -CoresLimit 100 -VmScaleSetCount 20

$NetworkQuota = New-AzsNetworkQuota -Name best-network `
 -Location local -PublicIpsPerSubscription 20 -VNetsPerSubscription 20 `
 -GatewaysPerSubscription 10 -ConnectionsPerSubscription 1000 -NicsPerSubscription 10000
if (!($StorageQuota = Get-AzsStorageQuota -Name best-storage))
    {
        $StorageQuota = New-AzsStorageQuota -Name best-storage -Location local `
        -NumberOfStorageAccounts 300 -CapacityInGB 50000
    }
 

## create a plan
$PCF_PLAN = New-AzsPlan -Name PCF-Plan -DisplayName "plan for pcf /cf" `
-ResourceGroupName $rg_name `
-QuotaIds $StorageQuota.Id,$NetworkQuota.Id,$ComputeQuota.Id -ArmLocation local
$Offer = New-AzsOffer -Name best-offer -DisplayName "Offer for PCF / Cloud Foundry" `
 -BasePlanIds $PCF_PLAN.Id -State Private -ArmLocation local -ResourceGroupName $rg_name
New-AzsUserSubscription -DisplayName "Azure PCF Subscription" -Owner $Global:Service_RM_Account.Context.Account.Id -OfferId $Offer.Id 