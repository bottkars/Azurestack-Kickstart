[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-kickstart")]
param (
[Parameter(ParameterSetName = "1", Mandatory = $false, Position = 1,ValueFromPipelineByPropertyName = $true)][ValidateSet(  
'FrontEndsScaleSet',
'LargeWorkerTierScaleSet',
'ManagementServersScaleSet',
'MediumWorkerTierScaleSet',
'PublishersScaleSet',
'SharedWorkerTierScaleSet',
'SmallWorkerTierScaleSet'
)]$WorkerTier,
[int][ValidateRange(0,10)]$scale,
[string]$ResourceGroup = "Appservice.local"
)
$rmvms = Get-AzureRmVmss -ResourceGroupName $ResourceGroup -VMScaleSetName $WorkerTier
$rmvms.Sku.Capacity = $scale
$rmvms | Update-AzureRmVmss