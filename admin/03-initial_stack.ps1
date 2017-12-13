﻿[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-dsc")]
param (
[Parameter(ParameterSetName = "1", Mandatory = $false,Position = 1)][ValidateScript({ Test-Path -Path $_ })]$Defaultsfile="$HOME/admin.json",
[switch]$noutils
)

$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($OldShell.IsPresent -or !$myWindowsPrincipal.IsInRole($adminRole))
{
 $arguments = "-Defaultsfile $Defaultsfile"
if ($noutils.IsPresent){
  $arguments = "-noutils"}
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
if (!(Get-Module -ListAvailable AZzureRM.BootStrapper))
  {
    Write-Host "==>Installing AzureRM Bootstrapper"
    Install-Module `
      -Name AzureRm.BootStrapper `
      -Force
  }
  else {
    Update-Module AzureRM.BootStrapper
  }  


if ($AzureRMProfileInstalled = Get-AzureRmProfile)
  {
    Write-Host "==> uninstalling $($AzureRMProfileInstalled.ProfileName)"
    Uninstall-AzureRmProfile -Profile $AzureRMProfileInstalled.ProfileName -Force 
  }   
Write-Host "==>Checking for old Powershell Modules" -NoNewline
$Azurestack_modules = Get-Module -ListAvailable AzureStack
Write-Host -ForegroundColor Green " [done]"
if ($Azurestack_modules)
  {
    Write-Host "==> Removing old Azurestack Modules" -NoNewline
    $azurestack_modules | Remove-Module
    Remove-item $($Azurestack_modules.ModuleBase) -Force -Recurse
    Write-Host -ForegroundColor Green " [done]"
    }
#Remove-Item "$HOME/Documents/WindowsPowerShell/Modules/Azure*" -Recurse -ErrorAction SilentlyContinue | Out-Null
# Uninstall any existing Azure PowerShell modules. To uninstall, close all the active PowerShell sessions, and then run the following command:
Write-Host "==>Checking for old Azure Powershell Modules" 

foreach ($modules in ("AzureRM.*","Azure.*"))
    {
  $My_Modules = Get-Module -ListAvailable $modules
  foreach ($module in $my_Modules)
      {
      if ($Module.Name -ne "AzureRM.BootStrapper")  
        {
        Write-Host "Trying to remove $module"  
        $Module | Remove-Module  #-ErrorAction SilentlyContinue -Force
        Write-Host "Trying to uninstall $module"
        try 
          {
          $Module | Uninstall-Module -ErrorAction Stop -Force
          }
        catch 
          {
          Write-Host "Forcing by deletion"
          Remove-Item $module.ModuleBase -Force -Recurse
          }
        }  
      }
  }
# Get-Module -ListAvailable | where-Object {$_.Name -like “Azure*”} | Uninstall-Module
Write-Host -ForegroundColor Green " [done]"
Remove-Module  AzureStack.Connect -ErrorAction SilentlyContinue  
Remove-Item $Global:AZSTools_location -Force -Recurse | Out-Null 

# Install PowerShell for Azure Stack.


Use-AzureRmProfile `
  -Profile "$($Admin_Defaults.AzureRmProfile)" `
  -Force -Scope CurrentUser

Install-Module `
  -Name AzureStack `
  -MinimumVersion "$($Admin_Defaults.AzureSTackModuleVersion)" `
  -Force -Scope CurrentUser
git clone  https://github.com/bottkars/AzureStack-Tools/ --branch patch-2 --singlebranch $Global:AZSTools_location


Import-Module "$($Global:AZSTools_location)/Connect/AzureStack.Connect.psm1"
# Register an AzureRM environment that targets your Azure Stack instance
  Add-AzureRMEnvironment `
    -Name "AzureStackAdmin" `
    -ArmEndpoint "$($Admin_Defaults.ArmEndpoint)"
