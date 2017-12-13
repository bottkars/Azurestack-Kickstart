[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-dsc")]
param (
[switch]$noutils
)
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