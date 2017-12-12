$Updates_path = "D:\Updates"
#http://care.dlservice.microsoft.com/dl/download/1/4/9/149D5452-9B29-4274-B6B3-5361DBDA30BC/14393.0.161119-1705.RS1_REFRESH_SERVER_EVAL_X64FRE_EN-US.ISO
                

# latest http://download.windowsupdate.com/d/msdownload/update/software/updt/2017/11/windows10.0-kb4051033-x64_6e6a9d355d051a231e289a6d7931dd8f979f8d0c.msu
$Latest_CU = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2017/11/windows10.0-kb4051033-x64_6e6a9d355d051a231e289a6d7931dd8f979f8d0c.msu"
$update_file = split-path -leaf $Latest_CU
#Start-BitsTransfer -Description "Getting latest 2016CU" -Destination $Updates_path -Source $Latest_CU
Import-Module "$Global:AZTools_location\Connect\AzureStack.Connect.psm1"
Import-Module "$Global:AZTools_location\ComputeAdmin\AzureStack.ComputeAdmin.psm1"
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


$ISOPath = "$home/Downloads/14393.0.161119-1705.RS1_REFRESH_SERVER_EVAL_X64FRE_EN-US.ISO"
# Add a Windows Server 2016 Evaluation VM image.
New-AzsServer2016VMImage -ISOPath $ISOPath -Version Both -CUPath $Updates_path/$update_file -CreateGalleryItem:$true -Location local 