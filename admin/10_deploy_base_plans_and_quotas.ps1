#//Azs.ServiceAdmin
#requires -module Azs.Compute.Admin
#requires -module Azs.Storage.Admin
[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-kickstart")]
param (
    [Parameter(ParameterSetName = "1", Mandatory = $false, Position = 1)]$plan_name = "BASE_$($(new-guid).guid)"
)
if (!$Global:SubscriptionID) {
    Write-Warning -Message "You Have not Configured a SubscriptionID, did you run 99_bootstrap.ps1 ?"
    break
}
if (!$Global:Service_RM_Account.Context) {
    Write-Warning -Message "You aree not signed in to your Azure RM Environment as Serviceadmin. Please run .\admin\99_bootstrap.ps1"
    break
}
$name = $plan_name
$rg_name = "plans_and_offers"
try {
    Write-Host -ForegroundColor White -NoNewline "Checking for RG $rg_name"
    $RG=Get-AzResourceGroup -Name $rg_name -Location local -ErrorAction Stop  
}
catch {
    Write-Host -ForegroundColor Red [failed]
    Write-Host -ForegroundColor White -NoNewline "Creating RG $rg_name"        
    $RG = New-AzResourceGroup -Name $rg_name -Location local
}
Write-Host -ForegroundColor Green [Done]

Write-Host -ForegroundColor White -NoNewline "Creating Quota $($name)_compute"
$ComputeQuota = New-AzsComputeQuota -Name "$($name)_compute" -Location local # -VirtualMachineCount 5000
Write-Host -ForegroundColor Green [Done]

Write-Host -ForegroundColor White -NoNewline "Creating Quota $($name)_Network"
$NetworkQuota = New-AzsNetworkQuota -Name "$($name)_network" -Location local # -PublicIpsPerSubscription 20 -VNetsPerSubscription 20 -GatewaysPerSubscription 10 -ConnectionsPerSubscription 1000 -NicsPerSubscription 10000
Write-Host -ForegroundColor Green [Done]

Write-Host -ForegroundColor White -NoNewline "Creating Quota $($name)_Storage"
$StorageQuota = New-AzsStorageQuota -Name "$($name)_storage" -Location local -NumberOfStorageAccounts 10 -CapacityInGB 500 
# -SkipCertificateValidation
Write-Host -ForegroundColor Green [Done]

## create a plan
Write-Host -ForegroundColor White -NoNewline "Creating $($name)_Plan"
$PLAN = New-AzsPlan -Name "$($name)_plan" -DisplayName "$name Plan" -ResourceGroupName $rg_name -QuotaIds $StorageQuota.Id, $NetworkQuota.Id, $ComputeQuota.Id -Location local
Write-Host -ForegroundColor Green [Done]


Write-Host -ForegroundColor White -NoNewline "Creating $($name)_Offer"
$Offer = New-AzsOffer -Name "$($name)_offer" -DisplayName "$name Offer" -BasePlanIds $PLAN.Id -Location local -ResourceGroupName $rg_name
# -State Public
Write-Host -ForegroundColor Green [Done]

Write-Host -ForegroundColor White -NoNewline "Creating Subscription $($name) Subsription"
$SubScription = New-AzsUserSubscription -DisplayName "$name Subscription" -Owner $global:ServiceAdmin -OfferId $Offer.Id 
Write-Host -ForegroundColor Green [Done]

Write-Output $SubScription