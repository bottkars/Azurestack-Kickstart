### stack config

$TenantName = "karstenbottemc.onmicrosoft.com"

# Set the module repository and the execution policy.
Set-PSRepository `
  -Name "PSGallery" `
  -InstallationPolicy Trusted

Set-ExecutionPolicy RemoteSigned `
  -force

# Uninstall any existing Azure PowerShell modules. To uninstall, close all the active PowerShell sessions, and then run the following command:
Get-Module -ListAvailable | `
  where-Object {$_.Name -like “Azure*”} | `
  Uninstall-Module

# Install PowerShell for Azure Stack.
Install-Module `
  -Name AzureRm.BootStrapper `
  -Force

Use-AzureRmProfile `
  -Profile 2017-03-09-profile `
  -Force

Install-Module `
  -Name AzureStack `
  -RequiredVersion 1.2.11 `
  -Force 
Set-Location C:\
git clone https://github.com/Azure/AzureStack-Tools 

cd AzureStack-Tools

Import-Module .\Connect\AzureStack.Connect.psm1

# For Azure Stack development kit, this value is set to https://adminmanagement.local.azurestack.external. To get this value for Azure Stack integrated systems, contact your service provider.
  $ArmEndpoint = "https://adminmanagement.local.azurestack.external"

# For Azure Stack development kit, this value is adminvault.local.azurestack.external 
$KeyvaultDnsSuffix = “adminvault.local.azurestack.externa”


# Register an AzureRM environment that targets your Azure Stack instance
  Add-AzureRMEnvironment `
    -Name "AzureStackAdmin" `
    -ArmEndpoint $ArmEndpoint

# Get the Active Directory tenantId that is used to deploy Azure Stack
  $TenantID = Get-AzsDirectoryTenantId `
    -AADTenantName $TenantName `
    -EnvironmentName "AzureStackAdmin"

# Sign in to your environment
  Login-AzureRmAccount `
    -EnvironmentName "AzureStackAdmin" `
    -TenantId $TenantID 


ipmo 


$cred = Get-Credential
Enter-PSSession -ComputerName "azs-ercs01.azurestack.local"`
      -ConfigurationName PrivilegedEndpoint -Credential $cred

$CloudAdminCredential = Get-Credential -UserName "Azurestack\Cloudadmin"
Add-AzsRegistration -CloudAdminCredential $CloudAdminCredential -AzureDirectoryTenantName $TenantName -AzureSubscriptionId "8c21cadc-9e41-459e-bf4b-919aa2fad975" -PrivilegedEndpoint "azs-ercs01" -BillingModel Development 

