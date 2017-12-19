[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-dsc")]
param (
[Parameter(ParameterSetName = "1", Mandatory = $false, Position = 1,ValueFromPipelineByPropertyName = $true)][ValidateSet(  
'MediumWorkerTierScaleSet','MediumWorkerTierScale','MediumWorkerTierScale')]$WorkerTier,
[int][ValidateRange(1,10)]$scale,
[string]$ResourceGroup = "Appservice.local"
)
$rmvms = Get-AzureRmVmss -ResourceGroupName $ResourceGroup -VMScaleSetName $WorkerTier
$rmvms.Sku.Capacity = $scale
$rmvms | Update-AzureRmVmss