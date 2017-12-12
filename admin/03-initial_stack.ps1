[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-dsc")]
param (
[Parameter(ParameterSetName = "1", Mandatory = $false,Position = 1)][ValidateScript({ Test-Path -Path $_ })]$Defaultsfile="$HOME/admin.json",
[switch]$noutils
)

if (!(Test-Path $Defaultsfile))
{
    Write-Warning "$Defaultsfile file does not exist.please copy from admin.json.example"
    Break
}
else
    {
    Write-Host -ForegroundColor Gray " ==>loading Admin Enviromment from $Defaultsfile"
    try {
        $Admin_Defaults = Get-Content $Defaultsfile | ConvertFrom-Json -ErrorAction SilentlyContinue   
    }
    catch {
        Write-Host "could not load $Defaultsfile, maybe a format error ?"
        break
    }
    
    Write-Output $Admin_Defaults
    }

$Global:VMPassword = $Admin_Defaults.VMPassword
$Global:TenantName = $Admin_Defaults.TenantName
$Global:ServiceAdmin = "$($Admin_Defaults.serviceuser)@$Global:TenantName"
$Global:AZSTools_location = $Admin_Defaults.AZSTools_Location
if (!$noutils.IsPresent)
    {
  $Utils = ("install-chrome","install-gitscm","Create-AZSportalsshortcuts")
  foreach ($Util in $Utils)
      {
      Install-Script $Util -Scope CurrentUser -Force -Confirm:$false
      ."$util.ps1"
      }
  }    
Set-PSRepository `
  -Name "PSGallery" `
  -InstallationPolicy Trusted

Set-ExecutionPolicy RemoteSigned `
  -force

# Uninstall any existing Azure PowerShell modules. To uninstall, close all the active PowerShell sessions, and then run the following command:
Get-Module -ListAvailable | `
  where-Object {$_.Name -like “Azure*”} | `
  Uninstall-Module -ErrorAction SilentlyContinue
# Get-Module -ListAvailable | where-Object {$_.Name -like “Azure*”} | Uninstall-Module

# Install PowerShell for Azure Stack.
Install-Module `
  -Name AzureRm.BootStrapper `
  -Force

Use-AzureRmProfile `
  -Profile $($Admin_Defaults.AzureRmProfile) `
  -Force

Install-Module `
  -Name AzureStack `
  -RequiredVersion $($Admin_Defaults.AzureSTackModuleVersion) `
  -Force 
git clone  https://github.com/Azure/AzureStack-Tools/  $Global:AZSTools_location


Import-Module "$($Global:AZSTools_location)/Connect/AzureStack.Connect.psm1"
# Register an AzureRM environment that targets your Azure Stack instance
  Add-AzureRMEnvironment `
    -Name "AzureStackAdmin" `
    -ArmEndpoint $Admin_Defaults.ArmEndpoint
