
[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-dsc")]
param ([Parameter(ParameterSetName = "1", Mandatory = $false,Position = 1)][ValidateSet('af-ZA',
'sq-AL','ar-DZ','ar-BH','ar-EG','ar-IQ','ar-JO','ar-KW','ar-LB','ar-LY','ar-MA','ar-OM','ar-QA','ar-SA','ar-SY','ar-TN','ar-AE','ar-YE',
'hy-AM','Cy-az-AZ','Lt-az-AZ','eu-ES','be-BY','bg-BG','ca-ES','zh-CN','zh-HK','zh-MO','zh-SG','zh-TW','zh-CHS','zh-CHT','hr-HR','cs-CZ',
'da-DK','div-MV','nl-BE','nl-NL',
'en-AU','en-BZ','en-CA','en-CB','en-IE','en-JM','en-NZ','en-PH','en-ZA','en-TT','en-GB','en-US','en-ZW','et-EE',
'fo-FO','fa-IR','fi-FI','fr-BE','fr-CA','fr-FR','fr-LU','fr-MC','fr-CH','gl-ES','ka-GE',
'de-AT','de-DE','de-LI','de-LU','de-CH',
'el-GR','gu-IN','he-IL','hi-IN','hu-HU','is-IS','id-ID','it-IT','it-CH','ja-JP','kn-IN','kk-KZ','kok-IN','ko-KR','ky-KZ','lv-LV','lt-LT','mk-MK','ms-BN','ms-MY','mr-IN','mn-MN',
'nb-NO','nn-NO','pl-PL','pt-BR','pt-PT','pa-IN','ro-RO','ru-RU','sa-IN','Cy-sr-SP','Lt-sr-SP','sk-SK','sl-SI',
'es-AR','es-BO','es-CL','es-CO','es-CR','es-DO','es-EC','es-SV','es-GT','es-HN','es-MX','es-NI','es-PA','es-PY','es-PE','es-PR','es-ES','es-UY','es-VE',
'sw-KE','sv-FI','sv-SE','syr-SY','ta-IN','tt-RU','te-IN','th-TH','tr-TR','uk-UA','ur-PK','Cy-uz-UZ','Lt-uz-UZ','vi-VN'
)]$LanguageTag = "en-US",
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
  $arguments = "$arguments -LanguageTag $LanguageTag"
  $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
  $newProcess.Arguments = "-noexit $PSScriptRoot/$($myinvocation.MyCommand) $arguments" 
  Write-Host $newProcess.Arguments
  $newProcess.Verb = "runas"
  [System.Diagnostics.Process]::Start($newProcess)
  exit
  }

Set-Location $Home

Write-Host -ForegroundColor White -NoNewline  "[==>]Disabling Windows Update"    
Start-Process "sc" -ArgumentList "config wuauserv start=disabled" -Wait -NoNewWindow
Write-Host -ForegroundColor Green "[Done]"

Write-Host -ForegroundColor Gray "[==>]setting language to $LanguageTag"
$Locale = $LanguageTag -replace "_","-"
Set-Culture $Locale | Out-Null
Set-WinSystemLocale $Locale | Out-Null
Set-WinUserLanguageList -LanguageList $Locale -Force | Out-Null
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

Write-Host "[==]now cloning into Azurestack Kickstart[==]"
git clone https://github.com/bottkars/Azurestack-DSC