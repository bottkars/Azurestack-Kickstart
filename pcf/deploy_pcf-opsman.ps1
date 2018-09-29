param(
    [Parameter(ParameterSetName = "1", Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.2-build.296.vhd',
        'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.1-build.214.vhd',
        'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.1-build.304.vhd',
        'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.1-build.314.vhd',
        'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.1-build.326.vhd',
        'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.1-build.335.vhd',
        'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.2-build.292.vhd',
        'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.2-build.296.vhd',
        'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.2-build.300.vhd',
        'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.2-build.305.vhd',
        'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.2-build.312.vhd',
        'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.2-build.316.vhd',
        'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.2-build.319.vhd',
        'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.3-build.146.vhd',
        'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.3-build.167.vhd'
    )]
    $opsmanager_uri = 'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.3-build.167.vhd',
    # The name of the Ressource Group we want to Deploy to.
    [Parameter(ParameterSetName = "1", Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    $resourceGroup = 'PCF_RG',
    # region of the Deployment., local for ASDK
    [Parameter(ParameterSetName = "1", Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    $location = $GLOBAL:AZS_Location,
   # [Parameter(ParameterSetName = "1", Mandatory = $false)]
   # [ValidateNotNullOrEmpty()]
   # $dnsdomain = $Global:dnsdomain,
    [Parameter(ParameterSetName = "1", Mandatory = $false)]
    $storageaccount,
    # The Containername we will host the Images for Opsmanager in
    [Parameter(ParameterSetName = "1", Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    $image_containername = 'opsman-image',
    # The SSH Key for OpsManager
    [Parameter(ParameterSetName = "1", Mandatory = $true)]$OPSMAN_SSHKEY,
    $opsManFQDNPrefix = "pcfopsman",
    $dnsZoneName = "pcfdemo.local.azurestack.external",
    [switch]$RegisterProviders,
    [switch]$OpsmanUpdate,
    [Parameter(ParameterSetName = "1", Mandatory = $false)][ValidateSet('green', 'blue')]$deploymentcolor = "green",
    [ipaddress]$subnet = "10.0.0.0",
    $downloadpath = "$($HOME)/Downloads",
    [switch]$useManagedDisks
)
if (!$location) {
    $Location = Read-Host "Please enter your Region Name [local for asdk]"
}
#if (!$dnsdomain) {
#    $dnsdomain = Read-Host "Please enter your DNS Domain [azurestack.external for asdk]"
#}
$blobbaseuri = (Get-AzureRmContext).Environment.StorageEndpointSuffix
$BaseNetworkVersion = [version]$subnet.IPAddressToString
$mask = "$($BaseNetworkVersion.Major).$($BaseNetworkVersion.Minor)"
Write-Host "Using the following Network Assignments:" -ForegroundColor Magenta
Write-Host "Management: $Mask.4.0/22"
Write-Host "Services: $Mask.8.0/22"
Write-Host "Deployment: $Mask.12.0/22"
Write-Host "$($opsManFQDNPrefix)green $Mask.4.4/32"
Write-Host "$($opsManFQDNPrefix)blue $Mask.4.5/32"
Write-Host
$opsManFQDNPrefix = "$opsManFQDNPrefix$deploymentcolor"
if (!$storageaccount) {
    $storageaccount = 'opsmanstorage'
    $storageaccount = ($resourceGroup + $Storageaccount) -Replace '[^a-zA-Z0-9]', ''
    $storageaccount = ($Storageaccount.subString(0, [System.Math]::Min(23, $storageaccount.Length))).tolower()
}
$opsManVHD = Split-Path -Leaf $opsmanager_uri
$opsmanVersion = $opsManVHD -replace ".vhd", ""
Write-host "Preparing to deploy OpsMan $opsmanVersion for $deploymentcolor deployment" -ForegroundColor $deploymentcolor
$storageType = 'Standard_LRS'
$file = split-path -Leaf $opsmanager_uri
$localPath = "$Downloadpath/$file"

if (!(Test-Path $localPath)) {
    Start-BitsTransfer -Source $opsmanager_uri -Destination $localPath -DisplayName OpsManager
}
if ($RegisterProviders.isPresent) {
    foreach ($provider in
        ('Microsoft.Compute',
            'Microsoft.Network',
            #'Microsoft.KeyVault',
            'Microsoft.Storage')
    ) {
        Get-AzureRmResourceProvider -ProviderNamespace $provider | Register-AzureRmResourceProvider
    }
}

if (!$OpsmanUpdate) {
    Write-Host "Creating ResourceGroup $resourceGroup"
    $new_rg = New-AzureRmResourceGroup -Name $resourceGroup -Location $location
    Write-Host "Creating StorageAccount $storageaccount"
    $new_acsaccount = New-AzureRmStorageAccount -ResourceGroupName $resourceGroup `
        -Name $storageAccount -Location $location `
        -Type $storageType
}

$urlOfUploadedImageVhd = ('https://' + $storageaccount + '.blob.' + $blobbaseuri + '/' + $image_containername + '/' + $opsManVHD)

try {
    Write-Host "uploading $opsManVHD into storageaccount $storageaccount, this may take a while"
    $new_arm_vhd = Add-AzureRmVhd -ResourceGroupName $resourceGroup -Destination $urlOfUploadedImageVhd `
        -LocalFilePath $localPath -ErrorAction SilentlyContinue
}
catch {
    Write-Warning "Image already exists for $opsManVHD, not overwriting"

}

if ( $useManagedDisks.IsPresent) {
    $ManagedDisks = "yes"
}
else {
    $ManagedDisks = "no" 
}
$parameters = @{}
$parameters.Add("SSHKeyData", $OPSMAN_SSHKEY)
$parameters.Add("opsManFQDNPrefix", $opsManFQDNPrefix)
$parameters.Add("storageAccountName", $storageaccount)
$parameters.Add("opsManVHD", $opsManVHD)
$parameters.Add("deploymentcolor", $deploymentcolor)
$parameters.Add("mask", $mask)
$parameters.Add("location", $location)
$parameters.Add("storageEndpoint", "blob.$blobbaseuri")
$parameters.Add("useManagedDisks", $ManagedDisks)

Write-host "Starting $deploymentcolor Deployment of $opsManFQDNPrefix $opsmanVersion" -ForegroundColor $deploymentcolor
if (!$OpsmanUpdate) {
    $parameters.Add("dnsZoneName", $dnsZoneName) 
    New-AzureRmResourceGroupDeployment -Name $resourceGroup -ResourceGroupName $resourceGroup -Mode Incremental -TemplateFile .\pcf\azuredeploy.json -TemplateParameterObject $parameters
    $MyStorageaccount = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroup | Where-Object StorageAccountName -match $storageaccount
    $MyStorageaccount | Set-AzureRmCurrentStorageAccount
    Write-Host "Creating Container Stemcell in $($MyStorageaccount.StorageAccountName)"
    $Container = New-AzureStorageContainer -Name stemcell -Permission Blob
    Write-Host  "Creating Container bosh in $($MyStorageaccount.StorageAccountName)"
    $Container = New-AzureStorageContainer -Name bosh
    Write-Host "Creating Table Stemcells in $($MyStorageaccount.StorageAccountName)"
    $Table = New-AzureStorageTable -Name stemcells
    if (!$useManagedDisks.IsPresent) {
        $Storageaccounts = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroup | Where-Object StorageAccountName -match Xtra
        foreach ($Mystorageaccount in $Storageaccounts) {
            $MyStorageaccount | Set-AzureRmCurrentStorageAccount
            Write-Host "Creating Container Stemcell in $($MyStorageaccount.StorageAccountName)"
            $Container = New-AzureStorageContainer -Name stemcell -Permission Blob
            Write-Host "Creating Container bosh in $($MyStorageaccount.StorageAccountName)"
            $Container = New-AzureStorageContainer -Name bosh
        }
    }
}
else {
    New-AzureRmResourceGroupDeployment -Name OpsManager -ResourceGroupName $resourceGroup -Mode Incremental -TemplateFile .\pcf\azuredeploy_update.json -TemplateParameterObject $parameters
 
}


##// create storage containers






    
<#
create a key
ssh-keygen -t rsa -f opsman -C ubuntu
 ssh -i opsman ubuntu@pcf-opsman.local.cloudapp.azurestack.external



<# register provider network storage keyvault, compute "!!!!!! 

login ui



https://docs.pivotal.io/pivotalcf/2-1/customizing/ops-man-api.html
uaac target https://pcf-opsman.local.cloudapp.azurestack.external/uaa --skip-ssl-validation
uaac token owner get

$ uaac token owner get
Client ID: opsman
Client secret: [Leave Blank]
User name: OPS-MAN-USERNAME
Password: OPS-MAN-PASSWORD


token="$(uaac context | awk '/^ *access_token\: *([a-zA-Z0-9.\/+\-_]+) *$/ {print $2}' -)"
curl "https://pcf-opsman.local.cloudapp.azurestack.external/api/v0/vm_types" \
    -X GET \
    -H "Authorization: bearer $token" \
    --insecure




curl -k https://pcf-opsman.local.cloudapp.azurestack.external/api/v0/vm_types -X \
PUT -H "Authorization: bearer $token" -H \
"Content-Type: application/json" -d '{"vm_types":[
{"name":"Standard_DS1_v2","ram":3584,"cpu":1,"ephemeral_disk":51200},
{"name":"Standard_DS2_v2","ram":7168,"cpu":2,"ephemeral_disk":102400},
{"name":"Standard_DS3_v2","ram":14336,"cpu":4,"ephemeral_disk":204800},
{"name":"Standard_DS4_v2","ram":28672,"cpu":8,"ephemeral_disk":409600},
{"name":"Standard_DS5_v2","ram":57344,"cpu":8,"ephemeral_disk":819200},
{"name":"Standard_DS11_v2","ram":14336,"cpu":2,"ephemeral_disk":102400},
{"name":"Standard_DS12_v2","ram":28672,"cpu":4,"ephemeral_disk":204800},
{"name":"Standard_DS13_v2","ram":57344,"cpu":8,"ephemeral_disk":409600},
{"name":"Standard_DS14_v2","ram":114688,"cpu":16,"ephemeral_disk":819200}]}' --insecure



###

$URI = "https://vmimage.blob.local.azurestack.external/vmimage/aliases.json"

az cloud register `
  -n AzureStackUser `
  --endpoint-resource-manager "https://management.local.azurestack.external" `
  --suffix-storage-endpoint "local.azurestack.external" `
  --suffix-keyvault-dns ".vault.local.azurestack.external" `
  --endpoint-active-directory-graph-resource-id "https://graph.windows.net/" `
  --endpoint-vm-image-alias-doc $uri

  #>