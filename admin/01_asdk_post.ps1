[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-kickstart")]
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
)]$LanguageTag = "en-US"
)
Write-Host -ForegroundColor White -NoNewline  "[==>]Disabling Windows Update"    
Start-Process "sc" -ArgumentList "config wuauserv start=disabled" -Wait -NoNewWindow
Write-Host -ForegroundColor Green "[Done]"
Write-Host -ForegroundColor Gray "[==>]setting language to $LanguageTag"
$Locale = $LanguageTag -replace "_","-"
Set-Culture $Locale | Out-Null
Set-WinSystemLocale $Locale | Out-Null
Set-WinUserLanguageList -LanguageList $Locale -Force | Out-Null
Write-Host -ForegroundColor Green "[Done]"
$AZDCredential = Get-Credential -UserName "Azurestack\AzurestackAdmin" -Message "Enter AD Credentials for AzureStackAdmin"
$AZSvms = get-vm -Name AZS*
$scriptblock = {
$env:COMPUTERNAME    
sc.exe config wuauserv start=disabled
Get-Service -Name wuauserv | fl StartType,Status,PSremote
}
foreach ($vm in $AZSvms) {
Invoke-Command -VMName $vm.name -ScriptBlock $scriptblock -Credential $AZDCredential
}
Set-ADDefaultDomainPasswordPolicy -MaxPasswordAge 180.00:00:00 -Identity azurestack.local
