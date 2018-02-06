
[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-kickstart")]
param (
    [Parameter(ParameterSetName = "1", Mandatory = $true,Position = 1)][ValidateScript({ Test-Path -Path $_ })]$ImagePath=$Global:ImagePath,
    [Parameter(ParameterSetName = "1", Mandatory = $true,Position = 1)][ValidateSet('Centos-7')]$Distribution,
    [Parameter(ParameterSetName = "1", Mandatory = $true,Position = 1)][ValidateSet('1711','1710','1708','1707','1706')]$Build,
    [alias('sku_version')][version]$osImageSkuVersion # = (date -Format yyyy.MM.dd).ToString()
)




begin {
    if (!$Global:SubscriptionID)
        {
        Write-Warning -Message "You Have not Configured a SubscriptionID, did you run 99_bootstrap.ps1 ?"
        break
        }  
$qemuimg = "$env:ProgramFiles\qemu\qemu-img.exe"
if (!(Test-Path $qemuimg))
    {
        Install-Script install-qemu-img
        install-qemu-img.ps1 -force
    }
switch ($Distribution)
    {
        'Centos-7'
            {
                $Versions = (get-content "$PSScriptRoot/Centos-7.json" | ConvertFrom-Json)
            }
    }

}
process
{

    $Version = $Versions | where { $_.Build -Match "$Build"}
    $QCOW2_Image = Split-Path -Leaf $($Version.URL)
    $VHD_Image = "$($QCOW2_Image.Split('.')[0]).vhd"
    $Publisher = $($Version.Version -split '-')[0]
    $Offer = ($Version.version.split('.'))[0]
    $osImageSkuVersion = $($Version.Version -split '-')[1]+'.'+$($Version.Build)+'.'+$($Version.Date).Replace('.','')
    $SKU = $($Version.Version)
    Write-Host -ForegroundColor White "[==>]Checking $Global:AZS_location Marketplace for $SKU $osImageSkuVersion " -NoNewline
    $evalnum = 0
    try {
        $AzureRMVMImage = Get-AzureRmVMImage -Location $Global:AZS_location -PublisherName $Publisher `
        -Offer $Offer -Skus $SKU `
        -Version $osImageSkuVersion -ErrorAction Stop | Out-Null
        }
    catch {
        $evalnum += 1
        Write-Host -ForegroundColor Red "[>>Not Found]"  
    }
    if ($evalnum -gt 0)
        {
        Write-Host -ForegroundColor White "[==>]Checking for $VHD_Image" -NoNewline
        if (!(Test-Path (join-path $ImagePath $VHD_Image)))
            {
                if (!(Test-Path (join-path $ImagePath $QCOW2_Image) ))
                    {
                        Write-Host -ForegroundColor White "[==>]We need to Download $($version.URL)" -NoNewline
                        Start-BitsTransfer -Source $Version.URL -Destination $ImagePath -DisplayName $QCOW2_Image
                    }
            Write-Host -ForegroundColor Green [Done]
            Write-Host -ForegroundColor White "[==>]Creating $VHD_Image from $QCOW2_Image" -NoNewline
            .$qemuimg convert -f qcow2 -o subformat=fixed -O vpc "$ImagePath/$QCOW2_Image" "$ImagePath/$VHD_Image"
            Write-Host -ForegroundColor Green [Done]
            }
        else {
            Write-Host -ForegroundColor Green [Done]
        } 
        Write-Host -ForegroundColor White "[==>]Starting Image Upload of $VHD_Image for Publisher $Publisher as offer $Offer with SKU $SKU and Version $osImageSkuVersion"
        $AzureRMVMImage = Add-AzsVMImage `
        -publisher $Publisher `
        -offer $Offer `
        -sku $SKU `
        -version $osImageSkuVersion `
        -osType Linux `
        -osDiskLocalPath "$ImagePath/$VHD_Image"
        #$AzureRMVMImage = Get-AzureRmVMImage -Location $Global:AZS_location -PublisherName $Publisher `
        #-Offer $Offer -Skus $SKU `
        #-Version $osImageSkuVersion -ErrorAction Stop | Out-Null
    }
else {
    Write-Host -ForegroundColor Green "[ok]"
    Write-Host -ForegroundColor White "[==>]$Global:AZS_location Marketplace is already populated with $SKU $osImageSkuVersion"
    Write-Output $AzureRMVMImage
    }            
}

end {

}