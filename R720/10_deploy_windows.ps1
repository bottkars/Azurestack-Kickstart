$Updates_path = "D:\Updates"
# latest http://download.windowsupdate.com/d/msdownload/update/software/updt/2017/11/windows10.0-kb4051033-x64_6e6a9d355d051a231e289a6d7931dd8f979f8d0c.msu
$Latest_CU = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2017/11/windows10.0-kb4051033-x64_6e6a9d355d051a231e289a6d7931dd8f979f8d0c.msu"
$update_file = split-path -leaf $Latest_CU
#Start-BitsTransfer -Description "Getting latest 2016CU" -Destination $Updates_path -Source $Latest_CU
Import-Module .\Connect\AzureStack.Connect.psm1
Import-Module .\ComputeAdmin\AzureStack.ComputeAdmin.psm1
$GraphAudience = "https://graph.windows.net/"
$TenantName = "karstenbottemc.onmicrosoft.com"
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

Login-AzureRmAccount `
 -EnvironmentName "AzureStackAdmin" `
 -TenantId $TenantID
 

$ISOPath = "D:\en_windows_server_2016_x64_dvd_9327751.iso"
# Add a Windows Server 2016 Evaluation VM image.
New-AzsServer2016VMImage -ISOPath $ISOPath -Version Both -CUPath $Updates_path -CreateGalleryItem:$true -Location local -version (date -Format yyyy.MM.dd).ToString()
