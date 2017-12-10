$global:azsuser = "azsuser1"
$Global:TenantName = "karstenbottemc.onmicrosoft.com"
$global:azsuseraccount = "$global:azsuser@$Global:TenantName"
$global:AZS_MODULES_ROOT = "D:\AzureStack-Tools\"



if (!$azsuser_credentials)
    {
    $global:azsuser_credentials = Get-Credential -Message "Enter Azure User Password for $global:azsuser" -UserName $global:azsuseraccount
    }


#Set-ExecutionPolicy RemoteSigned
Import-Module AzureRM.AzureStackAdmin
Import-Module "$global:AZS_MODULES_ROOT\Connect\AzureStack.Connect.psm1"

# For Azure Stack development kit, this value is set to https://management.local.azurestack.external. To get this value for Azure Stack integrated systems, contact your service provider.
$Global:ArmEndpoint = "https://management.local.azurestack.external"

# For Azure Stack development kit, this value is set to https://graph.windows.net/. To get this value for Azure Stack integrated systems, contact your service provider.
$Global:GraphAudience = "https://graph.windows.net/"

# Register an AzureRM environment that targets your Azure Stack instance
Add-AzureRMEnvironment `
  -Name "AzureStackUser" `
  -ArmEndpoint $Global:ArmEndpoint

# Set the GraphEndpointResourceId value
Set-AzureRmEnvironment `
  -Name "AzureStackUser" `
  -GraphAudience $Global:GraphAudience

# Get the Active Directory tenantId that is used to deploy Azure Stack
$Global:TenantID = Get-AzsDirectoryTenantId `
  -AADTenantName "$Global:TenantName" `
  -EnvironmentName "AzureStackUser"

# Sign in to your environment
Login-AzureRmAccount `
  -EnvironmentName "AzureStackUser" `
  -TenantId $Global:TenantID `
  -Credential $global:azsuser_credentials