
<#PSScriptInfo

.VERSION 2.1

.GUID a6511736-a96f-4c6f-a8f2-2f4f877627c0

.AUTHOR Karsten.Bott@labbuildr.com

.COMPANYNAME 

.COPYRIGHT 

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#>

<# 

.DESCRIPTION 
 KickAss your Azure Stack ASDK with this kickstart 

#> 
[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-kickstart")]
param (
[switch]$noutils
)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::TLS12 
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
# Check to see if we are currently running "as Administrator"
if (!$myWindowsPrincipal.IsInRole($adminRole))
  {
  if ($noutils.IsPresent)
    {
        $arguments = "-noutils"
    }
  $arguments = "$arguments -LanguageTag $LanguageTag"  
  $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell"
  $newProcess.Arguments = "-noexit $PSScriptRoot/$($myinvocation.MyCommand) $arguments" 
  Write-Host $newProcess.Arguments
  $newProcess.Verb = "runas"
  [System.Diagnostics.Process]::Start($newProcess)
  exit
  }

Set-Location $Home


if (!$noutils.IsPresent)
{

$Utils = ("install-chrome","install-gitscm","Create-AZSportalsshortcuts",'install-qemu-img')
foreach ($Util in $Utils)
  {
  Write-Host -ForegroundColor White -NoNewline  "[==>]Installing $util"    
  Install-Script $Util -Scope CurrentUser -Force -Confirm:$false
  ."$util.ps1"
  Write-Host -ForegroundColor Green "[Done]"
  }
}
Write-Host "[==]now cloning into Azurestack Kickstart Environment[==]"
git clone https://github.com/bottkars/Azurestack-Kickstart 