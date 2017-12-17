[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-dsc")]
param(
[string][ValidateSet("Standard_A1","Standard_A2","Standard_A3")]$vmSku= "Standard_A1",
[string]$vmssName= "vmsswin$(get-random(99))", 
[int]$instanceCount = 3,         
[string]$adminUsername= $global:VMuser,
[securestring]$adminPassword= $global:VMPassword,                        
[string]$osImagePublisher="MicrosoftWindowsServer",
[string]$osImageOffer="WindowsServer",
[string][ValidateSet("2016-Datacenter","2016-Datacenter-Sevre-Core")]$osImageSku="2016-Datacenter",
# POS Image SKU Version
[Parameter(Mandatory = $False)][ValidateSet("14393.321.20161110",
"14393.351.20161027",
"14393.448.20161109",
"14393.479.20161209",
"14393.576.20161213",
"14393.693.20170110",
"14393.726.20170126",
"14393.729.20170130",
"14393.953.20170314",
"14393.969.20170320",
"14393.970.20170322",
"14393.1066.20170411",
"14393.1198.20170509",
"14393.1230.20170526",
"14393.1358.20170613",
"14393.1378.20170627",
"14393.1480.20170711",
"14393.1532.20170718",
"14393.1593.20170808",
"14393.1613.20170816",
"14393.1670.20170828",
"14393.1715.20170912",
"14393.1737.20170927",
"14393.1770.20171010",
"14393.1794.20171017",
"14393.1797.20171102",
"14393.1884.20171114",
"14393.1914.20171127",
"14393.1944.20171212")]
[alias('sku_version')][version]$osImageSkuVersion,
$resourcegroup_name = "rg_$vmssName"
)

$parameters = @{}
$parameters.Add("vmSKU",$vmSku)
$parameters.Add("vmssName",$vmssName)
$parameters.Add("instanceCount",$instanceCount)
$parameters.Add("adminusername",$adminUsername)
$parameters.Add("adminpassword",$adminPassword)
$parameters.Add("osImageOffer",$osImageOffer)
$parameters.Add("osImagePublisher",$osImagePublisher)
$parameters.Add("osImageSKU",$osImageSku)

$Templateuri = "https://raw.githubusercontent.com/bottkars/201_vmss_windows_skuversion/master/201_vmss_windows_skuversion/azuredeploy.json"
Write-host "[==>]Creating Resourcegroup $resourcegroup_name " -NoNewline
$RG = New-AzureRmResourceGroup -Name $resourcegroup_name -Location $Global:AZS_Location  
Write-Host -ForegroundColor Green "[Done]" 

Write-host "[==>]Starting Deployment  $($resourcegroup_name)_deploy for ResourceGroup $resourcegroup_name, this can take some minutes" -NoNewline
$RG | New-AzureRmResourceGroupDeployment -Name "$($resourcegroup_name)_deploy" `
 -TemplateUri $Templateuri -TemplateParameterObject $Parameters -Verbose:$False 
Write-Host -ForegroundColor Green "[Done]" 