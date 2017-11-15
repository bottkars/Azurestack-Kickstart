Set-PSRepository `
  -Name "PSGallery" `
  -InstallationPolicy Trusted


Get-Module -ListAvailable | where-Object {$_.Name -like “Azure*”} | Uninstall-Module


# Install the AzureRM.Bootstrapper module. Select Yes when prompted to install NuGet 
Install-Module `
  -Name AzureRm.BootStrapper

# Install and import the API Version Profile required by Azure Stack into the current PowerShell session.
Use-AzureRmProfile `
  -Profile 2017-03-09-profile -Force

Install-Module `
  -Name AzureStack `
  -RequiredVersion 1.2.11