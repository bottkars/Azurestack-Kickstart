$GraphAudience = "https://graph.windows.net/"

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
Import-Module .\ComputeAdmin\AzureStack.ComputeAdmin.psm1
# Add a Windows Server 2016 Evaluation VM image.
New-AzsServer2016VMImage -ISOPath $ISOPath -Version Both -CUPath D:\updates\windows10.0-kb4048953-x64_6fccbf0ed11c9dfbc8d13e50d81ccfe97d1e2b82.msu -CreateGalleryItem:$true -Location local 