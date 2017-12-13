
[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-dsc")]
param (
[switch]$noutils
)

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
  $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
  $newProcess.Arguments = "-noexit $PSScriptRoot/$($myinvocation.MyCommand) $arguments" 
  Write-Host $newProcess.Arguments
  $newProcess.Verb = "runas"
  [System.Diagnostics.Process]::Start($newProcess)
  exit
  }


Write-Host -ForegroundColor White -NoNewline  "[==>]Disabling WIndows Update"    
Start-Process "sc" -ArgumentList "config wuauserv start=disabled" -Wait -NoNewWindow
Write-Host -ForegroundColor Green "[Done]"
if (!$noutils.IsPresent)
{
$Utils = ("install-chrome","install-gitscm","Create-AZSportalsshortcuts")
foreach ($Util in $Utils)
  {
  Write-Host -ForegroundColor White -NoNewline  "[==>]Installing $util"    
  Install-Script $Util -Scope CurrentUser -Force -Confirm:$false
  ."$util.ps1"
  Write-Host -ForegroundColor Green "[Done]"
  }
} 