#//Azs.ServiceAdmin
#requires -module Azs.Compute.Admin
#requires -module Azs.Storage.Admin
[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-kickstart")]
param (
[Parameter(ParameterSetName = "1", Mandatory = $false,Position = 1)]$offer = "PCF_Offer",
$plan = "PCF_PLAN",
$rg_name = "plans_and_offers",
$owner = $Global:Service_RM_Account.Context.Account.Id
#$SubscriptionID = $Global:SubscriptionID
)
if (!$Global:SubscriptionID)
{
Write-Warning -Message "You Have not Configured a SubscriptionID, did you run 99_bootstrap.ps1 ?"
break
}
if (!$Global:Service_RM_Account.Context)
    {
    Write-Warning -Message "You are not signed in to your Azure RM Environment as Serviceadmin. Please run .\admin\99_bootstrap.ps1"
    break
    }

if (!($RG = Get-AzureRmResourceGroup -Name $rg_name -Location local))
    {
    Write-Host -ForegroundColor White -NoNewline "Creating RG $rg_name"
    $RG = New-AzureRmResourceGroup -Name $rg_name -Location local
    Write-Host -ForegroundColor Green [Done]
    }

try {
    $AZSOffer = Get-AzsManagedOffer -Name $offer -ResourceGroupName $rg_name -ErrorAction SilentlyContinue
}
catch {

      Write-Host "$Offer not found in $rg_name, we need to create it"
}
if  ($AZSOffer)
    {
        Write-Host "Offer with name $offer already exists in $rg_name"
        break
    }
if (!($ComputeQuota = Get-AzsComputeQuota -Name pcf-compute))
    {
    $ComputeQuota = New-AzsComputeQuota -Name pcf-compute `
    -Location local -VirtualMachineCount 200 `
    -AvailabilitySetCount 50 -CoresLimit 200 -VmScaleSetCount 10    
    }
if (!($NetworkQuota = Get-AzsNetworkQuota -Name pcf-network))
    {
    $NetworkQuota = New-AzsNetworkQuota -Name pcf-network `
    -Location local -MaxPublicIpsPerSubscription 20 -MaxVNetsPerSubscription 5 `
    -MaxVirtualNetworkGatewaysPerSubscription 5 `
    -MaxVirtualNetworkGatewayConnectionsPerSubscription 1000 -MaxNicsPerSubscription 200
    }


if (!($StorageQuota = Get-AzsStorageQuota -Name pcf-storage))
       {
           $StorageQuota = New-AzsStorageQuota -Name pcf-storage -Location local `
           -NumberOfStorageAccounts 300 -CapacityInGB 5000
       }


$PCF_PLAN = Get-AZSPlan -Name $plan -ResourceGroupName $rg_name -ErrorAction SilentlyContinue
if (!$PCF_PLAN) {
        Write-Host "$plan not found in $rg_name, creating now"
        $PCF_PLAN = New-AzsPlan -Name $plan -DisplayName "Offer for PCF" `
    	    -ResourceGroupName $rg_name `
            -QuotaIds $StorageQuota.Id,$NetworkQuota.Id,$ComputeQuota.Id -ArmLocation local
    }


$AZSOffer = New-AzsOffer -Name $offer -DisplayName "Offer for PCF / Cloud Foundry" `
 -BasePlanIds $PCF_PLAN.Id -State Private -ArmLocation local -ResourceGroupName $rg_name
New-AzsUserSubscription -DisplayName "Azure PCF Subscription" -Owner $owner -OfferId $AZSOffer.Id #-SubscriptionId $SubscriptionID
Write-Output $AZSOffer