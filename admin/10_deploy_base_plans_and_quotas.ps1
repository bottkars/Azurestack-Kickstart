#requires -module AzureStack.ServiceAdmin
#requires -module AzureStack.ComputeAdmin
#requires -module AzureRM.AzureStackStorage
[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-dsc")]
param (
[Parameter(ParameterSetName = "1", Mandatory = $false,Position = 1)]$plan_name = "BASE_$($(new-guid).guid)"
)
if (!$Global:SubscriptionID)
{
Write-Warning -Message "You Have not Configured a SubscriptionID, did you run 99_bootstrap.ps1 ?"
break
}
if (!$Global:Service_RM_Account.Context)
    {
    Write-Warning -Message "You aree not signed in to your Azure RM Environment as Serviceadmin. Please run .\admin\99_bootstrap.ps1"
    break
    }
$name = $plan_name
$rg_name = "plans_and_offers"
Write-Host -ForegroundColor White -NoNewline "Creating Quota $($name)_compute"
$ComputeQuota = New-AzsComputeQuota -Name "$($name)_compute" -Location local # -VirtualMachineCount 5000
Write-Host -ForegroundColor Green [Done]

Write-Host -ForegroundColor White -NoNewline "Creating Quota $($name)_Network"
$NetworkQuota = New-AzsNetworkQuota -Name "$($name)_network" -Location local # -PublicIpsPerSubscription 20 -VNetsPerSubscription 20 -GatewaysPerSubscription 10 -ConnectionsPerSubscription 1000 -NicsPerSubscription 10000
Write-Host -ForegroundColor Green [Done]

Write-Host -ForegroundColor White -NoNewline "Creating Quota $($name)_Storage"
$StorageQuota = New-AzsStorageQuota -Name "$($name)_storage" -Location local -NumberOfStorageAccounts 10 -CapacityInGB 500 -SkipCertificateValidation
Write-Host -ForegroundColor Green [Done]

## create a plan
Write-Host -ForegroundColor White -NoNewline "Creating $($name)_Plan"
$PLAN = New-AzsPlan -Name "$($name)_plan" -DisplayName "$name Plan" -ResourceGroupName $rg_name -QuotaIds $StorageQuota.Id,$NetworkQuota.Id,$ComputeQuota.Id -ArmLocation local
Write-Host -ForegroundColor Green [Done]


Write-Host -ForegroundColor White -NoNewline "Creating $($name)_Offer"
$Offer = New-AzsOffer -Name "$($name)_offer" -DisplayName "$name Offer" -State Public -BasePlanIds $PLAN.Id -ArmLocation local -ResourceGroupName $rg_name
Write-Host -ForegroundColor Green [Done]

Write-Host -ForegroundColor White -NoNewline "Creating Subscription $($name) Subsription"
$SubScription =  New-AzsUserSubscription -DisplayName "$name Subscription" -Owner "Azurestack Admin" -OfferId $Offer.Id 
Write-Host -ForegroundColor Green [Done]

Write-Output $SubScription