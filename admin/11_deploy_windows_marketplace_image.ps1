[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-dsc")]
param (
[Parameter(ParameterSetName = "1", Mandatory = $false,Position = 1)][ValidateScript({ Test-Path -Path $_ })]$ISOPath="$HOME/Downloads",
[Parameter(ParameterSetName = "1", Mandatory = $false,Position = 2)][ValidateScript({ Test-Path -Path $_ })]$UpdatePath="$HOME/Downloads",
[Parameter(ParameterSetName = "1", Mandatory = $false, Position = 3,ValueFromPipelineByPropertyName = $true)][ValidateSet(
'KB4053579','KB4051033','KB4048953','KB4052231','KB4041688','KB4041691','KB4038801','KB4038782','KB4039396','KB4034661','KB4034658'
)]$KB,
[version]$sku_version # = (date -Format yyyy.MM.dd).ToString()
)
#REQUIRES -Module AzureStack.Connect
#REQUIRES -Module AzureStack.ComputeAdmin
#REQUIRES -RunAsAdministrator
begin {
    Remove-Item "./$PSScriptRoot/*.vhd"
    $Updates = (get-content $PSScriptRoot\windowsupdate.json | ConvertFrom-Json)
    $Updates = $Updates |  Sort-Object -Descending -Property Date
}

process {

if (!$sku_version)
    {
        [string]$SKU_DATE = (get-date $Updates[0].Date -Format "yyyy.MM").ToString()
        [version]$sku_version = "$($Updates[0].BUILD).$($SKU_DATE.ToString())"
    }
Write-Host -ForegroundColor White "[==]Using sku Version $($sku_version.toString())[==]"
if (!$KB)
    {
        $Latest_KB = $Updates[0].URL  
    }
else
    {
        $Latest_KB = ($Updates | where KB -match $KB).url
    }

$Latest_ISO = "http://care.dlservice.microsoft.com/dl/download/1/4/9/149D5452-9B29-4274-B6B3-5361DBDA30BC/14393.0.161119-1705.RS1_REFRESH_SERVER_EVAL_X64FRE_EN-US.ISO"
$update_file = split-path -leaf $Latest_KB
$updateFilePath = Join-Path $UpdatePath $update_file
$ISO_FILE = Split-path -Leaf $Latest_ISO
$ISOFilePath = Join-Path $ISOPath $ISO_FILE
Write-Host -ForegroundColor White "[==>]Checking for $($Updates[-1].KB)" -NoNewline
if (!(test-path $updateFilePath))
    {
    Start-BitsTransfer -Description "Getting latest 2016KB $($Updates[-1].KB)" -Destination $UpdatePath -Source $Latest_KB
    }
Write-Host -ForegroundColor Green [Done]
Write-Host -ForegroundColor White "[==>]Checking for $ISO_FILE" -NoNewline
If (!(test-path $ISOFilePath))
    {
    Start-BitsTransfer -Description "Getting latest 2016ISO" -Destination $ISOPath -Source $Latest_ISO
    }
Write-Host -ForegroundColor Green [Done]
<#
$GraphAudience = "https://graph.windows.net/"
$TenantName = $Global:TenantName
$ArmEndpoint = "https://adminmanagement.local.azurestack.external"

# Create the Azure Stack operator's Azure Resource Manager environment by using the following cmdlet:
Add-AzureRMEnvironment `
 -Name "AzureStackAdmin" `
 -ArmEndpoint $ArmEndpoint

Set-AzureRmEnvironment `
 -Name "AzureStackAdmin" `
 -GraphAudience $GraphAudience

$TenantID = Get-AzsDirectoryTenantId `
 -AADTenantName $TenantName `
 -EnvironmentName AzureStackAdmin
#>
# Add a Windows Server 2016 Evaluation VM image.
New-AzsServer2016VMImage -ISOPath $ISOFilePath -Version Both -CUPath $updateFilePath -CreateGalleryItem:$true -Location local -sku_version $sku_version
Remove-Item "./$PSScriptRoot/*.vhd"
}
end {}