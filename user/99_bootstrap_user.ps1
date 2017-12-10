$Global:azsuser = "azsuser1"
$Global:TenantName = "karstenbottemc.onmicrosoft.com"
$global:azsuseraccount = "$Global:azsuser@$Global:TenantName"
$global:AZS_MODULES_ROOT = "D:\AzureStack-Tools\"
if (!$azsuser_credentials)
    {
    $global:azsuser_credentials = Get-Credential -Message "Enter Azure User Password for $global:azsuser" -UserName $global:azsuseraccount
    }
Import-Module AzureRM.AzureStackAdmin
Import-Module "$global:AZS_MODULES_ROOT\Connect\AzureStack.Connect.psm1"
$Global:ArmEndpoint = "https://management.local.azurestack.external"
$Global:GraphAudience = "https://graph.windows.net/"
Add-AzureRMEnvironment `
  -Name "AzureStackUser" `
  -ArmEndpoint $Global:ArmEndpoint

Set-AzureRmEnvironment `
  -Name "AzureStackUser" `
  -GraphAudience $Global:GraphAudience

$Global:TenantID = Get-AzsDirectoryTenantId `
  -AADTenantName "$Global:TenantName" `
  -EnvironmentName "AzureStackUser"

Login-AzureRmAccount `
  -EnvironmentName "AzureStackUser" `
  -TenantId $Global:TenantID `
  -Credential $global:azsuser_credentials