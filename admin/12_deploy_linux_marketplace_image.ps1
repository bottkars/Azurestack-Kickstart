
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

if (!(Test-Path "$env:ProgramFiles\qemu\qemu-img.exe"))
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
    $ImageFile = Split-Path -Leaf $($Version.URL)
    if (!(Test-Path (join-path $ImagePath $ImageFile) ))
        {
            Write-Host "We need to Download $($version.URL)"
            Start-BitsTransfer -Source $Version.URL -Destination $ImagePath -DisplayName $imageFile
        }
}



end {

}