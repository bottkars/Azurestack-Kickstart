
[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-kickstart")]
param (
    [Parameter(ParameterSetName = "centos", Mandatory = $true,Position = 1)][ValidateSet('Centos-7.4')][alias('cver')]$CentosDistribution,
    [Parameter(ParameterSetName = "centos", Mandatory = $true,Position = 1)][ValidateSet('1711','1710','1708','1707','1706')]$CentosBuild,
    [Parameter(ParameterSetName = "ubuntu", Mandatory = $true,Position = 1)][ValidateSet('16.04-LTS','18.04-LTS','14.04.05-LTS')][alias('uver')]$UbuntuVersion,
    [Parameter(Mandatory = $false,Position = 1)][ValidateScript({ Test-Path -Path $_ })]$ImagePath=$Global:ImagePath,
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
        Install-Script install-qemu-img -force
        install-qemu-img.ps1 -force
    }
switch ($PsCmdlet.ParameterSetName)
    {
        'centos'
            {
                $Versions = (get-content "$PSScriptRoot/Centos-7.json" | ConvertFrom-Json)
                $build = $CentosBuild
                $Distribution = $CentosDistribution
            }
        'ubuntu'
            {
                $Versions = (get-content "$PSScriptRoot/Ubuntu.json" | ConvertFrom-Json)
                $version = $versions | where {$_.Version -match $UbuntuVersion}
                $build = $Version.Release
                add-type -AssemblyName "system.io.compression.filesystem"
            }
    }    

}
process
{




switch ($PsCmdlet.ParameterSetName)
    {
        'centos'
            {
                $Version = $Versions | where { $_.Build -Match "$Build"}
                $QCOW2_Image = Split-Path -Leaf $($Version.URL)
                $VHD_Image = "$($QCOW2_Image.Split('.')[0]).vhd"
                $Publisher = $($Version.Version -split '-')[0]
                $Offer = ($Version.version.split('.'))[0]
                $osImageSkuVersion = $($Version.Version -split '-')[1]+'.'+$($Version.Build)
                $SKU = $($Version.Version)
                Write-Host -ForegroundColor White "[==>]Checking $Global:AZS_location Marketplace for $SKU $osImageSkuVersion" -NoNewline
                $evalnum = 0
                try {
                    $AzureRMVMImage = Get-AzureRmVMImage -Location $Global:AZS_location -PublisherName $Publisher `
                    -Offer $Offer -Skus $SKU `
                    -Version $osImageSkuVersion -ErrorAction Stop 
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
                }
            }
        'ubuntu'
            {
                Write-Host "Analyzing Content ... "
                if ($version.release -match "http")
                    {
                        $result = Invoke-WebRequest -Uri $version.release
                        $title = $result.ParsedHtml.title
                        Write-Host "found $title"
                        $my = ($title -split "\[")[1]
                        $release = $my -replace $my[-1]
                    }
                else
                    {
                        $release = $version.release
                    }    
                write-host "using release $release as SKU Version"
                $File = Join-Path $ImagePath $(Split-Path -Leaf $version.URL)
                $VHD_Image_path = $File -replace ".zip"
                if ($version.release -match "http")
                {
                    Write-Host "Daily Build, deleting old Download"
                    Remove-Item $File -Force -ErrorAction SilentlyContinue
                    Remove-Item $VHD_Image_path -Force -ErrorAction SilentlyContinue
                }
                if (!(test-path $VHD_Image_path))    
                {
                    if (!(Test-Path $File))
                        {
                        Start-BitsTransfer -Source $Version.URL -Destination $ImagePath
                        }    
                    try {
                        Write-Host "Extracting $File"
                        $vhd_fileinfo = Expand-Archive -LiteralPath $File -DestinationPath $ImagePath -Force
                        $VHD_Image_path = [System.IO.Compression.zipfile]::OpenRead("$File").entries.name
                    }
                    catch {
                        Write-Host "Error extracting $file"
                        Break
                    }
                }

                $VHD_Image = Split-Path -Leaf $VHD_Image_path    
                $evalnum ++
                $Offer_version = $version.Version -replace "-"," "
                $Publisher = "Canonical"
                $Offer = "Ubuntu Server $Offer_version"
                $sku = $version.Version
                $osImageSkuVersion = "$(($version.Version).Substring(0,5)).$($Release.Substring(0,8))"
            }
    }  
    if ($evalnum -gt 0)
        {   
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
        }
    Write-Output $AzureRMVMImage
}

end {

}