[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-dsc")]
param (
[Parameter(ParameterSetName = "1", Mandatory = $false,Position = 1)][ValidateScript({ Test-Path -Path $_ })]$ISOPath=$Global:ISOPath,
[Parameter(ParameterSetName = "1", Mandatory = $false,Position = 2)][ValidateScript({ Test-Path -Path $_ })]$UpdatePath=$Global:UpdatePath,
[Parameter(ParameterSetName = "1", Mandatory = $false, Position = 3,ValueFromPipelineByPropertyName = $true)][ValidateSet(
'KB4053579','KB4051033','KB4048953','KB4052231','KB4041688','KB4041691','KB4038801',
'KB4038782','KB4039396','KB4034661','KB4034658','KB4025334','KB4025339','KB4022723',
'KB4022715','KB4023680','KB4019472','KB4015217','KB4016635','KB4015438','KB4013429',
'KB4010672','KB3216755','KB3213986','KB3206632','KB3201845','KB3194798','KB3200970',
'KB3197954',
'KB4056890')]$KB,
[alias('sku_version')][version]$osImageSkuVersion # = (date -Format yyyy.MM.dd).ToString()
)
#REQUIRES -Module AzureStack.Connect
#REQUIRES -Module AzureStack.ComputeAdmin
#REQUIRES -RunAsAdministrator
begin {
    if (!$Global:SubscriptionID)
        {
        Write-Warning -Message "You Have not Configured a SubscriptionID, did you run 99_bootstrap.ps1 ?"
        break
        }    
    Remove-Item "$Global:AZSTools_location\ComputeAdmin\*.vhd" -force -ErrorAction SilentlyContinue
    $Updates = (get-content $PSScriptRoot\windowsupdate.json | ConvertFrom-Json)
    $Updates = $Updates |  Sort-Object -Descending -Property Date
    $azserverimage = @()
}

process {

if (!$KB)
    {
        $Latest_KB = $Updates[0].URL
        $KB =  $Updates[0].KB  
    }
else
    {
        $Latest_KB = ($Updates | Where-Object KB -match $KB).url
    }
if (!$osImageSkuVersion)
    {
        $Version = $Updates | Where-Object {$_.KB -match $KB}
        [string]$SKU_DATE = (get-date $Version.Date -Format "yyyyMMdd").ToString()
        [string]$osImageSkuVersion = "$($Version.BUILD).$($SKU_DATE.ToString())"
    }
Write-Host -ForegroundColor White "[==>]Checking $Global:AZS_location Marketplace for 2016-Datacenter $osImageSkuVersion " -NoNewline
$evalnum = 0
try {
    Get-AzureRmVMImage -Location $Global:AZS_location -PublisherName MicrosoftWindowsServer `
    -Offer WindowsServer -Skus 2016-Datacenter `
    -Version $osImageSkuVersion -ErrorAction Stop | Out-Null
    }
catch {
    $evalnum += 1
    Write-Host " >>Not Found" -NoNewline  
}
Write-Host -ForegroundColor Green [Done]
Write-Host -ForegroundColor White "[==>]Checking $Global:AZS_location Marketplace for 2016-Datacenter-Server-Core $osImageSkuVersion " -NoNewline
try {
    Get-AzureRmVMImage -Location $Global:AZS_location -PublisherName MicrosoftWindowsServer `
    -Offer WindowsServer -Skus 2016-Datacenter-Server-Core `
    -Version $osImageSkuVersion -ErrorAction Stop | Out-Null
}
catch {
    $evalnum += 2
    Write-Host " >>Not Found" -NoNewline
}
Write-Host -ForegroundColor Green [Done]
# 1= server, 2 = core, 3= both
switch ($evalnum)
    {
        1
            { 
            $image_version = "FULL"
            }
        2
            { 
            $image_version = "CORE"
            }
        3
            { 
            $image_version = "BOTH"
            }
        0
            { 
            $image_version = "NONE"
            }               
    }

Write-Host -ForegroundColor White "[==]Need to create $image_version WindowsServer images for $osImageSkuVersion[==]" 
if ($image_version -ne "NONE")
    {
    Write-Host -ForegroundColor White "[==]Using sku Version $($osImageSkuVersion.toString())[==]"
    $Latest_ISO = "http://care.dlservice.microsoft.com/dl/download/1/4/9/149D5452-9B29-4274-B6B3-5361DBDA30BC/14393.0.161119-1705.RS1_REFRESH_SERVER_EVAL_X64FRE_EN-US.ISO"
    $update_file = split-path -leaf $Latest_KB
    $update_cab = "$(($update_file -split "_")[0]).cab"
    $updateFilePath = Join-Path $UpdatePath $update_file
    $ISO_FILE = Split-path -Leaf $Latest_ISO
    $ISOFilePath = Join-Path $ISOPath $ISO_FILE
    Write-Host -ForegroundColor White "[==>]Checking for $KB" -NoNewline
    if (!(test-path $updateFilePath))
        {
        Start-BitsTransfer -Description "Getting latest 2016KB $KB" -Destination $UpdatePath -Source $Latest_KB
        }
    Write-Host -ForegroundColor Green [Done]
    Write-Host -ForegroundColor White "[==>]Checking for $ISO_FILE" -NoNewline
    If (!(test-path $ISOFilePath))
        {
        Start-BitsTransfer -Description "Getting latest 2016ISO" -Destination $ISOPath -Source $Latest_ISO
        }
    Write-Host -ForegroundColor Green [Done]

    Write-Host -ForegroundColor White "[==>]Creating image for $osImageSkuVersion" -NoNewline
    $azserverimage += New-AzsServer2016VMImage -ISOPath $ISOFilePath -Version $image_version `
        -CUPath $updateFilePath -CreateGalleryItem:$true `
        -Location local -Sku_Version $osImageSkuVersion -Verbose:$false
    Write-Host -ForegroundColor Green [Done]
    Write-Host -ForegroundColor White "[==>]Removing VHD´s for $osImageSkuVersion" -NoNewline
    $remove = Remove-Item "$Global:AZSTools_location\ComputeAdmin\*.vhd" -force -ErrorAction SilentlyContinue
    Write-Host -ForegroundColor Green [Done]
    Write-Host -ForegroundColor White "[==>]removing $update_cab" -NoNewline
    $remove = Remove-Item "$UpdatePath\$update_cab" -force -ErrorAction SilentlyContinue
    Write-Host -ForegroundColor Green [Done]
    }
$osImageSkuVersion =""
}
end {

    Write-Output $azserverimage

}