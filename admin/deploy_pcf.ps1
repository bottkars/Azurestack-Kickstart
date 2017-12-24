
<#
$TenantID = Get-AzsDirectoryTenantId -AADTenantName $TenantName -EnvironmentName "AzureStackAdmin"

Login-AzureRmAccount -EnvironmentName "AzureStackAdmin" -TenantId $TenantID
$ComputeQuota = New-AzsComputeQuota -Name best-compute -Location local -VirtualMachineCount 5000
$NetworkQuota = New-AzsNetworkQuota -Name best-network -Location local -PublicIpsPerSubscription 20 -VNetsPerSubscription 20 -GatewaysPerSubscription 10 -ConnectionsPerSubscription 1000 -NicsPerSubscription 10000
$StorageQuota = New-AzsStorageQuota -Name best-storage -Location local -NumberOfStorageAccounts 300 -CapacityInGB 50000 -SkipCertificateValidation
## create a plan
$PCF_PLAN = New-AzsPlan -Name best-plan -DisplayName "best-plan for pcf" -ResourceGroupName "pcf-plan-rg" -QuotaIds $StorageQuota.Id,$NetworkQuota.Id,$ComputeQuota.Id -ArmLocation local
$Offer = New-AzsOffer -Name best-offer -DisplayName "Offer for PCF" -State Public -BasePlanIds $PCF_PLAN.Id -ArmLocation local -ResourceGroupName "pfc-offer-rg"
New-AzsTenantSubscription -DisplayName "Azure PCF Subscription" -Owner "Karsten Bott" -OfferId $Offer.Id 

#$opsmanager_uri  = "https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-$($ops_mgr_version).vhd"
#Start-BitsTransfer -Source $opsmanager_uri -Destination C:\Temp #>


<# register provider network storage fevault, compute "!!!!!! #>

$RESOURCE_GROUP = "RG_PCF_MINIMUM"
$LOCATION = $GLOBAL:AZS_Location

$RSG = New-AzureRmResourceGroup -Name $RESOURCE_GROUP -Location $LOCATION
$PCF_NSG = New-AzureRmNetworkSecurityGroup -Name "pfc-nsg" -ResourceGroupName $RESOURCE_GROUP -Location $LOCATION
Add-AzureRmNetworkSecurityRuleConfig -Name ssh -NetworkSecurityGroup $PCF_NSG -Protocol Tcp -Priority 100 -DestinationPortRange 22
Add-AzureRmNetworkSecurityRuleConfig -Name http -NetworkSecurityGroup $PCF_NSG -Protocol Tcp -Priority 200 -DestinationPortRange 80


## OpsMGR NSG opsmgr-nsg
$OPSMGR_NSG = New-AzureRmNetworkSecurityGroup -Name "opsmgr-nsg" -ResourceGroupName $RESOURCE_GROUP -Location $LOCATION
Add-AzureRmNetworkSecurityRuleConfig -Name ssh -NetworkSecurityGroup $OPSMGR_NSG -Protocol Tcp -Priority 100 -DestinationPortRange 22
Add-AzureRmNetworkSecurityRuleConfig -Name http -NetworkSecurityGroup $OPSMGR_NSG -Protocol Tcp -Priority 200 -DestinationPortRange 80
Add-AzureRmNetworkSecurityRuleConfig -Name https -NetworkSecurityGroup $OPSMGR_NSG -Protocol Tcp -Priority 300 -DestinationPortRange 443

# vnets
$vnet = New-AzureRmVirtualNetwork -Name pcf-net -ResourceGroupName $RESOURCE_GROUP -Location $LOCATION -AddressPrefix 10.0.0.0/16
Add-AzureRmVirtualNetworkSubnetConfig -Name pcf -VirtualNetwork $vnet -AddressPrefix 10.0.0.0/20
$Storage_Account = New-AzureRmStorageAccount -ResourceGroupName $RESOURCE_GROUP -Name "boshstorageaccount" -Type Standard_LRS -Location $LOCATION
$OpsManage_Container = $Storage_Account | New-AzureStorageContainer -Name opsmanager -Permission Off
$Bosh_Container = $Storage_Account | New-AzureStorageContainer -Name bosh -Permission Off
$Stemcell_Container =$Storage_Account | New-AzureStorageContainer -Name stemcell -Permission Blob
$Stemcell_table = $Storage_Account | New-AzureStorageTable -Name stemcells


$Ops_Manegr_vhd = Set-AzureStorageBlobContent -Container $OpsManage_Container.Name `
    -File  $HOME\Downloads\ops-manager-2.0-build.213.vhd -Context $Storage_Account.Context
$Deployment_Storage_Account = New-AzureRmStorageAccount -ResourceGroupName $RESOURCE_GROUP `
 -Name "deploymentstorageaccount" -Type Standard_LRS -Location $LOCATION
$Deployment_bosh_container = $Deployment_Storage_Account | New-AzureStorageContainer -Name bosh -Permission Off
$Deployment_stemcell_container = $Deployment_Storage_Account | New-AzureStorageContainer -Name stemcell -Permission Off


$PublicIP = New-AzureRmPublicIpAddress -Name pcf-lb-ip -ResourceGroupName $RESOURCE_GROUP -Location $LOCATION -AllocationMethod Static


$LB_FRONTEND_CONFIG =  New-AzureRmLoadBalancerFrontendIpConfig -Name pcf-fe-ip -PublicIpAddress $PublicIP
$LB_PROBE_CONFIG = New-AzureRmLoadBalancerProbeConfig -Name tcp80 -Protocol Tcp -Port 80 -IntervalInSeconds 30 -ProbeCount 5

$pcf_lbbepool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name pcf-lbbepool 
$HTTP_RULE = New-AzureRmLoadBalancerRuleConfig -Protocol Tcp -Name http -FrontendPort 80 -BackendPort 80 -BackendAddressPool $pcf_lbbepool -FrontendIpConfiguration $LB_FRONTEND_CONFIG -Probe $LB_PROBE_CONFIG
$HTTPs_RULE = New-AzureRmLoadBalancerRuleConfig -Protocol Tcp -Name https -FrontendPort 443 -BackendPort 443 -BackendAddressPool $pcf_lbbepool -FrontendIpConfiguration $LB_FRONTEND_CONFIG -Probe $LB_PROBE_CONFIG
$diegossh_RULE = New-AzureRmLoadBalancerRuleConfig -Protocol Tcp -Name diego-ssh -FrontendPort 2222 -BackendPort 2222 -BackendAddressPool $pcf_lbbepool -FrontendIpConfiguration $LB_FRONTEND_CONFIG -Probe $LB_PROBE_CONFIG

$pcf_lb = New-AzureRmLoadBalancer -Name pcf-lb -Location $LOCATION -ResourceGroupName $RESOURCE_GROUP `
 -FrontendIpConfiguration $LB_FRONTEND_CONFIG -LoadBalancingRule $HTTP_RULE,$HTTPs_RULE,$diegossh_RULE


$Opsmgr_VIP = New-AzureRmPublicIpAddress -Name ops-manager-ip -ResourceGroupName $RESOURCE_GROUP -Location $LOCATION -AllocationMethod Static 
 ### opsmanager

$vmName = "ops-manager-2.0"
$computerName = "ops-manager-2"
$vmSize = "Standard_DS1_v2"
$location = $Location
$imageName = "opsmanager"


$imageConfig = New-AzureRmImageConfig -Location $location
$imageConfig = Set-AzureRmImageOsDisk -Image $imageConfig -OsType Linux `
 -OsState Generalized `
 -BlobUri "https://boshstorageaccount.blob.local.azurestack.external/opsmanager/ops-manager-2.0-build.213.vhd"
$image = New-AzureRmImage -ImageName $imageName -ResourceGroupName $rgName -Image $imageConfig