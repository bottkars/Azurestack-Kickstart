
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
    $Publisher =($Version.Version -split '-')[0] 
    if (!(Test-Path (join-path $ImagePath $VHD_Image)))
        {
            if (!(Test-Path (join-path $ImagePath $QCOW2_Image) ))
                {
                    Write-Host "We need to Download $($version.URL)"
                    Start-BitsTransfer -Source $Version.URL -Destination $ImagePath -DisplayName $QCOW2_Image
                }
        .$qemuimg convert -f qcow2 -o subformat=fixed -O vpc "$ImagePath/$QCOW2_Image" "$ImagePath/$VHD_Image"
        }
    Add-AzsVMImage `
    -publisher $Publisher `
    -offer $Version.version `
    -sku "$($Version.Version)-$($Version.Build)" `
    -version $($Version.Date) `
    -osType Linux `
    -osDiskLocalPath "$ImagePath/$VHD_Image"        

}



end {

}