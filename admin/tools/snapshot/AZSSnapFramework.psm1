function New-AZSVMSnapShot {
param (
$ResourceGroupName 
)

$vms = @()
Write-Host "[==>]Evaluating VM´s in $ResourceGroupName"
$vms = Get-AzureRmVM  -ResourceGroupName $ResourceGroupName

if ($vms)
    {
    foreach ($VM in $vms)
        {
        write-host "[==>]found VM $($vm.name)"
        if ($vm.StorageProfile.OsDisk.Vhd.Uri)
            {
            Write-Host "[==>]Evaluating OS DisK for $($VM.Name)"
            $storageaccount = ($vm.StorageProfile.OsDisk.Vhd.Uri).Split('.')[0] -replace "https://"
            Write-Host "[==>]Got OS Disk for $($VM.Name)"
            Write-Host "[==>]Examining OS Disk $($vm.StorageProfile.OsDisk.Vhd.Uri)"
            $OSVHD = get-AZSSNAPVHDFROMURI -VHDUri $vm.StorageProfile.OsDisk.Vhd.Uri
            $Snapshot = create-AZSRMSnapShot -storageaccount $storageaccount -Container $OSVHD.Container -VHDFileName $OSVHD.VHDFileName
            Write-Output $Snapshot
            }
        else 
            {
            Write-Host "[==<]No OS Disk Found for $($VM.Name)"
            }
        Write-Host "[==>]Evaluating Data Disk(s) for $($VM.Name)"
        $DataDiskCount = 0
        if ($vm.StorageProfile.DataDisks.Count -gt 0)
            {
            write-host "[==>]Found $($vm.StorageProfile.DataDisks.Count) DataDisk(s) for $($VM.Name)"
            foreach ($Disknum  in 1..($vm.StorageProfile.DataDisks.count))
                {
                $storageaccount = ($vm.StorageProfile.DataDisks[$DataDiskcount].Vhd.Uri).Split('.')[0] -replace "https://"
                Write-Host "[==>]Got Data Disk $Disknum for $($VM.Name)"
                Write-Host "[==>]Examining DATA Disk $($vm.StorageProfile.DataDisks[$DataDiskCount].Vhd.Uri)"
                $DataDiskVHD = get-AZSSNAPVHDFROMURI -VHDUri $vm.StorageProfile.DataDisks[$DataDiskCount].Vhd.Uri
                $Snapshot = create-AZSRMSnapShot -storageaccount $storageaccount -Container $DataDiskVHD.Container -VHDFileName $DataDiskVHD.VHDFileName
                Write-Output $Snapshot
                $DataDiskCount++
                }
            } 
        else
            {
            write-host "[==<]No DataDisks Found for $($VM.Name)"
            }           
        }
    }
else 
    {
    Write-Host "No VM foud for $ResourceGroupName"
    }
}

function Create-AZSRMSnapShot 
{
param
(
$storageaccount,
$Container,
$VHDFileName
)
$RMRessource = Find-AzureRmResource -ResourceNameContains $StorageAccount
$AZRMSTorageAccount = Get-AzureRmStorageAccount -Name $storageaccount  -ResourceGroupName $RMRessource.ResourceGroupName
$AZRMSTorageAccountKey = Get-AzureRmStorageAccountKey -Name $storageaccount  -ResourceGroupName $RMRessource.ResourceGroupName
$AZRMSTorageContext = New-AzureStorageContext $storageaccount -StorageAccountKey $AZRMSTorageAccountKey.Key1
$VMblob = Get-AzureRmStorageAccount -Name $storageaccount -ResourceGroupName $RMRessource.ResourceGroupName | Get-AzureStorageContainer | where {$_.Name -eq $Container} | Get-AzureStorageBlob | where {$_.Name -eq $VHDFileName -and $_.ICloudBlob.IsSnapshot -ne $true}
Write-Host "[==>]Found Storage Blob $($VMblob.Name)"
Write-Host "[==>]Creating Snapshot for $($VMblob.Name)"
$VMsnap = $VMblob.ICloudBlob.CreateSnapshot()
Write-Host -ForegroundColor Magenta "Created Snapshot $($VMsnap.Name) at $($VMsnap.SnapshotTime)"
$blob = Get-AzureStorageContainer -Context $AZRMSTorageContext -Name $Container
$ListOfBlobs = $blob.CloudBlobContainer.ListBlobs($VHDFileName, $true, "Snapshots")
Write-Output $ListOfBlobs
}
function get-AZSSnapVHDfromURI {
param
(
[string]$VHDUri
)

$VHDinfo = ($VHDURI).Split('//')
$Container = $VHDinfo[3] 
$VHDFileName = split-path -leaf $VHDUri
$VHDName = $VHDFileName -replace ".vhd*"

    $Object = New-Object psobject
    $Object | Add-Member -MemberType NoteProperty -Name VHDName -Value $VHDName
    $Object | Add-Member -MemberType NoteProperty -Name Container -Value $Container
    $Object | Add-Member -MemberType NoteProperty -Name VHDFileNAME -Value $VHDFileName

Write-Output $Object
}
