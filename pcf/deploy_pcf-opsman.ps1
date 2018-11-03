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
        'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.3-build.167.vhd',
        'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.3-build.170.vhd',
        'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.3-build.184.vhd',
        'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.3-build.188.vhd'
    )]
    $opsmanager_uri = 'https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.3-build.188.vhd',
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
    [switch]$useManagedDisks,
    [Parameter(ParameterSetName = "1", Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('AzureCloud', 'AzureStack')]$Environment = "AzureStack"

)


function get-runningos 
{
    # backward copatibility for peeps runnin powershell 5
    write-verbose "trying to get os type ... "
    if ($env:windir) {
        $OS_Version = Get-Command "$env:windir\system32\ntdll.dll"
        $OS_Version = $OS_Version.Version
        $Global:deploy_os_type = "win_x86_64"
        $webrequestor = ".Net"
    }
    elseif ($OS = uname) {
        write-verbose "found OS $OS"
        Switch ($OS) {
            "Darwin" {
                $Global:deploy_os_type = "OSX"
                $OS_Version = (sw_vers -productVersion)
                write-verbose $OS_Version
                try {
                    $webrequestor = (get-command curl).Path
                }
                catch {
                    Write-Warning "curl not found"
                    exit
                }
            }
            'Linux' {
                $Global:deploy_os_type = "LINUX"
                $OS_Version = (uname -o)
                #$OS_Version = $OS_Version -join " "
                try {
                    $webrequestor = (get-command curl).Path
                }
                catch {
                    Write-Warning "curl not found"
                    exit
                }
            }
            default {
                write-verbose "Sorry, rome was not build in one day"
                exit
            }
            'default' {
                write-verbose "unknown linux OS"
                break
            }
        }
    }
    else {
        write-verbose "error detecting OS"
    }

    $Object = New-Object -TypeName psobject
    $Object | Add-Member -MemberType NoteProperty -Name OSVersion -Value $OS_Version
    $Object | Add-Member -MemberType NoteProperty -Name OSType -Value $deploy_os_type
    $Object | Add-Member -MemberType NoteProperty -Name Webrequestor -Value $webrequestor
    Write-Output $Object
}

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
$OpsManBaseUri = Split-Path  $opsmanager_uri  
$OpsmanContainer = Split-Path $OpsManBaseUri
$opsManVHD = Split-Path -Leaf $opsmanager_uri
$opsmanVersion = $opsManVHD -replace ".vhd", ""
Write-host "Preparing to deploy OpsMan $opsmanVersion for $deploymentcolor deployment" -ForegroundColor $deploymentcolor
$storageType = 'Standard_LRS'

$StopWatch_prepare = New-Object System.Diagnostics.Stopwatch
$StopWatch_deploy = New-Object System.Diagnostics.Stopwatch
$StopWatch_prepare.Start()

if (!$OpsmanUpdate) {
    Write-Host "==>Creating ResourceGroup $resourceGroup" -nonewline   
    $new_rg = New-AzureRmResourceGroup -Name $resourceGroup -Location $location
    Write-Host -ForegroundColor green "[done]"
    $account_available = Get-AzureRmStorageAccountNameAvailability -Name $storageaccount -ErrorAction SilentlyContinue
    if ($account_available.NameAvailable -eq $true) {
         Write-Host "==>Creating StorageAccount $storageaccount" -nonewline
    $new_acsaccount = New-AzureRmStorageAccount -ResourceGroupName $resourceGroup `
        -Name $storageAccount -Location $location `
        -Type $storageType
    Write-Host -ForegroundColor green "[done]"
    }
    else {
        Write-Host "$storageaccount already exists, operations might fail if not owner in same location" 
    }    
   
}
$urlOfUploadedImageVhd = ('https://' + $storageaccount + '.blob.' + $blobbaseuri + '/' + $image_containername + '/' + $opsManVHD)
Write-Host "Starting upload Procedure for $opsManVHD into storageaccount $storageaccount, this may take a while"
if ($Environment -eq 'AzureStack') {
    Write-Host "==>Checking OS Transfer Type" -nonewline 
    $transfer_type = (get-runningos).Webrequestor
    Write-Host -ForegroundColor Green "[using $transfer_type for transfer]"
    $file = split-path -Leaf $opsmanager_uri
    $localPath = "$Downloadpath/$file"
    if (!(Test-Path $localPath)) {
        switch ($transfer_type) {
            ".Net" {  
                Start-BitsTransfer -Source $opsmanager_uri -Destination $localPath -DisplayName OpsManager
            }
            Default {
                curl -o $localPath $opsmanager_uri
            }
        }
    }  
    try {
        $new_arm_vhd = Add-AzureRmVhd -ResourceGroupName $resourceGroup -Destination $urlOfUploadedImageVhd `
            -LocalFilePath $localPath -ErrorAction SilentlyContinue
    }
    catch {
        Write-Warning "Image already exists for $opsManVHD, not overwriting"
    }
}
else {
    # Blob Copy routine
    $src_context = New-AzureStorageContext -StorageAccountName opsmanagerwesteurope -Anonymous
    $dst_context = (Get-AzureRmStorageAccount -ResourceGroupName $resourceGroup -Name $storageaccount).context
    ## check for blob
    Write-Host "==>Checking blob $opsManVHD exixts in container $image_containername for Storageaccount $storageaccount" -NoNewline
    $ExistingBlob = Get-AzureStorageBlob -Context $dst_context -Blob $opsManVHD -Container $image_containername -ErrorAction SilentlyContinue
    if (!$ExistingBlob) {
        Write-Host -ForegroundColor Green "[blob needs to be uploaded]"
        # check container
        Write-Host "==>Checking container $image_containername exists for Storageaccount $storageaccount" -NoNewline
        $ContainerExists = (Get-AzureStorageContainer -Name $image_containername -Context $dst_context -ErrorAction SilentlyContinue)
        If (!$ContainerExists) {
            Write-Host -ForegroundColor Green "[creating container]"
            $container = New-AzureStorageContainer -Name $image_containername -Permission Off -Context $dst_context            
        }
        else {
            Write-Host -ForegroundColor blue "[container already exists]"
        }
        Write-Host "==>copying $opsManVHD into Storageaccount $storageaccount" -NoNewline
        $copy = Get-AzureStorageBlob -Container images -Blob $opsManVHD -Context $src_context | `
            Start-AzureStorageBlobCopy -DestContainer $image_containername -DestContext $dst_context
        $complete = $copy | Get-AzureStorageBlobCopyState -WaitForComplete
        Write-Host -ForegroundColor green "[done copying]"
    }
    else {
        Write-Host -ForegroundColor Blue "[blob already exixts]"
    }
}

$StopWatch_prepare.Stop()
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
$parameters.Add("OpsManImageURI", $urlOfUploadedImageVhd)
$parameters.Add("Environment", $Environment)

$StopWatch_deploy.Start()
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
    New-AzureRmResourceGroupDeployment -Name OpsManager -Location $location `
        -ResourceGroupName $resourceGroup -Mode Incremental -TemplateFile .\pcf\azuredeploy_update.json `
        -TemplateParameterObject $parameters
 
}
$StopWatch_deploy.Stop()

Write-Host "Preparation and BLOB copy job took $($StopWatch_prepare.Elapsed.Hours) hours, $($StopWatch_prepare.Elapsed.Minutes) minutes and $($StopWatch_prepare.Elapsed.Seconds) seconds" -ForegroundColor Magenta
Write-Host "ARM Deployment took $($StopWatch_deploy.Elapsed.Hours) hours, $($StopWatch_deploy.Elapsed.Minutes) minutes and  $($StopWatch_deploy.Elapsed.Seconds) seconds" -ForegroundColor Magenta

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