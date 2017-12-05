$serviceAdmin = "masadmin@karstenbottemc.onmicrosoft.com"
#$serviceAdminPass = ConvertTo-SecureString "Passw0rd" -AsPlainText -Force
$Global:ServiceAdminCreds = Get-Credential -UserName $serviceAdmin -Message "Enter Azure ServiceAdmin Password"

$CloudAdmin = "AzureStack\Cloudadmin"
$CloudAdminPass = ConvertTo-SecureString "Passw0rd" -AsPlainText -Force
$Global:CloudAdminCreds = New-Object System.Management.Automation.PSCredential($CloudAdmin, $CloudAdminPass)

$Global:TenantName = "karstenbottemc.onmicrosoft.com"
$Global:AZTools_location = "D:\AzureStack-Tools"

Import-Module "$AZTools_location\Connect\AzureStack.Connect.psm1" -Force
Import-Module AzureRM.AzureStackStorage -Force
Import-Module "$AZTools_location\serviceAdmin\AzureStack.ServiceAdmin.psm1" -Force
Import-Module "$AZTools_location\ComputeAdmin\AzureStack.ComputeAdmin.psm1" -Force

# For Azure Stack development kit, this value is set to https://adminmanagement.local.azurestack.external. To get this value for Azure Stack integrated systems, contact your service provider.
$Global:ArmEndpoint = "https://adminmanagement.local.azurestack.external"

# For Azure Stack development kit, this value is adminvault.local.azurestack.external 
$Global:KeyvaultDnsSuffix = “adminvault.local.azurestack.external”


# Register an AzureRM environment that targets your Azure Stack instance
  Add-AzureRMEnvironment `
    -Name "AzureStackAdmin" `
    -ArmEndpoint $ArmEndpoint

# Get the Active Directory tenantId that is used to deploy Azure Stack
  $Global:TenantID = Get-AzsDirectoryTenantId `
    -AADTenantName $TenantName `
    -EnvironmentName "AzureStackAdmin"

# Sign in to your environment
  Login-AzureRmAccount `
    -EnvironmentName "AzureStackAdmin" `
    -TenantId $TenantID -Credential $ServiceAdminCreds

Set-AzureRmEnvironment -Name AzureStackAdmin -GraphAudience https://graph.windows.net/