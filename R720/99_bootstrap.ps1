$serviceAdmin = "Karsten.Bott@emc.com"
$AdminCreds = Get-Credential -UserName $serviceAdmin -Message "specify service admin credentials"


$CloudAdminPass = ConvertTo-SecureString "Passw0rd" -AsPlainText -Force
$CloudAdminCreds = New-Object System.Management.Automation.PSCredential ("Azurestack\cloudadmin", $CloudAdminPass)

$TenantName = "karstenbottemc.onmicrosoft.com"

Import-Module C:\AzureStack-Tools\Connect\AzureStack.Connect.psm1

# For Azure Stack development kit, this value is set to https://adminmanagement.local.azurestack.external. To get this value for Azure Stack integrated systems, contact your service provider.
$ArmEndpoint = "https://adminmanagement.local.azurestack.external"

# For Azure Stack development kit, this value is adminvault.local.azurestack.external 
$KeyvaultDnsSuffix = “adminvault.local.azurestack.external”


# Register an AzureRM environment that targets your Azure Stack instance
  Add-AzureRMEnvironment `
    -Name "AzureStackAdmin" `
    -ArmEndpoint $ArmEndpoint

# Get the Active Directory tenantId that is used to deploy Azure Stack
  $TenantID = Get-AzsDirectoryTenantId `
    -AADTenantName $TenantName `
    -EnvironmentName "AzureStackAdmin"

# Sign in to your environment
  Login-AzureRmAccount `
    -EnvironmentName "AzureStackAdmin" `
    -TenantId $TenantID -Credential $AdminCreds