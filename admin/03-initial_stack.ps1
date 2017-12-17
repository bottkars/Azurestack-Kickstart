[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-dsc")]
param (
[Parameter(ParameterSetName = "1", Mandatory = $false,Position = 1)][ValidateScript({ Test-Path -Path $_ })]$Defaultsfile="$HOME/admin.json"
)

$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($OldShell.IsPresent -or !$myWindowsPrincipal.IsInRole($adminRole))
  {
  $arguments = "-Defaultsfile $Defaultsfile"
  $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
  $newProcess.Arguments = "-noexit $PSScriptRoot/$($myinvocation.MyCommand) $arguments" 
  Write-Host $newProcess.Arguments
  $newProcess.Verb = "runas"
  [System.Diagnostics.Process]::Start($newProcess) 
  exit
  }
[switch]$OldShell = $true
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
        Write-Host "could not load $Defaultsfile, maybe a format error ?
        try validate at https://jsonlint.com/"
        break
    }
    
    Write-Output $Admin_Defaults
    }

$Global:VMPassword = $Admin_Defaults.VMPassword 
$Global:TenantName = $Admin_Defaults.TenantName
$Global:ServiceAdmin = "$($Admin_Defaults.serviceuser)@$Global:TenantName"
$Global:AZSTools_location = $Admin_Defaults.AZSTools_Location
   
Set-PSRepository `
  -Name "PSGallery" `
  -InstallationPolicy Trusted

Set-ExecutionPolicy RemoteSigned `
  -force
if (!(Get-Module -ListAvailable AzureRM.BootStrapper))
  {
    Write-Host "[==>]Installing AzureRM Bootstrapper" -ForegroundColor White -NoNewline
    Install-Module `
      -Name AzureRm.BootStrapper `
      -Force -WarningAction SilentlyContinue
      Write-Host -ForegroundColor Green "[Done]"
  }
  else {
    Write-Host "[==>]Updating AzureRM Bootstrapper" -ForegroundColor White -NoNewline
    $mods = Update-Module AzureRM.BootStrapper -WarningAction SilentlyContinue
    Write-Host -ForegroundColor Green "[Done]"
  }  


if ($AzureRMProfileInstalled = Get-AzureRmProfile)
  {
    Write-Host -ForegroundColor White -NoNewline "[==>]uninstalling $($AzureRMProfileInstalled.ProfileName)"
    Uninstall-AzureRmProfile -Profile $AzureRMProfileInstalled.ProfileName -Force 
    Write-Host -ForegroundColor Green "[Done]"
  }   
Write-Host "[==>]Checking for old Powershell Modules" -NoNewline
$Azurestack_modules = Get-Module -ListAvailable AzureStack
Write-Host -ForegroundColor Green "[Done]"
if ($Azurestack_modules)
  {
    Write-Host "[==>]Removing old Azurestack Modules" -NoNewline
    $azurestack_modules | Remove-Module
    Remove-item $($Azurestack_modules.ModuleBase) -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host -ForegroundColor Green "[Done]"
    }
#Remove-Item "$HOME/Documents/WindowsPowerShell/Modules/Azure*" -Recurse -ErrorAction SilentlyContinue | Out-Null
# Uninstall any existing Azure PowerShell modules. To uninstall, close all the active PowerShell sessions, and then run the following command:
Write-Host "[==>]Checking for old Azure Powershell Modules" 

foreach ($modules in ("AzureRM.*","Azure.*"))
    {
  $My_Modules = Get-Module -ListAvailable $modules
  foreach ($module in $my_Modules)
      {
      if ($Module.Name -ne "AzureRM.BootStrapper")  
        {
        Write-Host -ForegroundColor White -NoNewline  "[==>]Trying to remove $module"  
        $Module | Remove-Module  #-ErrorAction SilentlyContinue -Force
        Write-Host -ForegroundColor Green "[Done]"
        
        Write-Host "[==>]Trying to uninstall $module" -ForegroundColor White -NoNewline
        try 
          {
          $Module | Uninstall-Module -ErrorAction Stop -Force
          }
        catch 
          {
          Write-Host -ForegroundColor Magenta " -->Forcing by deletion"
          Remove-Item $module.ModuleBase -Force -Recurse
          }
        Write-Host -ForegroundColor Green "[Done]"
        }  
      }
  }
# Get-Module -ListAvailable | where-Object {$_.Name -like “Azure*”} | Uninstall-Module
Write-Host -ForegroundColor Green "[Done]"
Write-Host -ForegroundColor White "[==>]Removing Module Azurestack.Connect" -NoNewline
Remove-Module  AzureStack.Connect -ErrorAction SilentlyContinue 
Write-Host -ForegroundColor Green "[Done]"

Remove-Item $Global:AZSTools_location -Force -Recurse -ErrorAction SilentlyContinue 

# Install PowerShell for Azure Stack.

Write-Host "[==>]" -ForegroundColor White -NoNewline
Use-AzureRmProfile `
  -Profile "$($Admin_Defaults.AzureRmProfile)" `
  -Force -Scope CurrentUser -WarningAction SilentlyContinue
Write-Host -ForegroundColor Green "[Done]"

Write-Host "[==>]Installing Module Azurestack Connect" -ForegroundColor White -NoNewline
$mod = Install-Module `
  -Name AzureStack `
  -MinimumVersion "$($Admin_Defaults.AzureSTackModuleVersion)" `
  -Force -Scope CurrentUser -WarningAction SilentlyContinue
Write-Host -ForegroundColor Green "[Done]"
  
Write-Host "[==>]Cloning into Azurestack-Tools" -ForegroundColor White -NoNewline
git clone  https://github.com/bottkars/AzureStack-Tools/ --branch patch-2 --single-branch $Global:AZSTools_location
Write-Host -ForegroundColor Green "[Done]"

Write-Host "[==>]Loading AzureStack.Connect" -ForegroundColor White -NoNewline
Import-Module "$($Global:AZSTools_location)/Connect/AzureStack.Connect.psm1"
Write-Host -ForegroundColor Green "[Done]"
# Register an AzureRM environment that targets your Azure Stack instance
Write-Host -ForegroundColor  White -NoNewline "[==>]Adding AzureStackAdmin RM Environment"
$Global:AzureRMEnvironment = Add-AzureRMEnvironment `
    -Name "AzureStackAdmin" `
    -ArmEndpoint "$($Admin_Defaults.ArmEndpoint)"
Write-Host -ForegroundColor Green "[Done]"