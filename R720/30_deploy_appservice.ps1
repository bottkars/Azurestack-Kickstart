$Location = new-item -ItemType Directory C:\Temp\AppService -Force
Set-Location $Location
Invoke-WebRequest https://aka.ms/appsvconmashelpers -OutFile AppServiceHelperScripts.zip
Expand-Archive AppServiceHelperScripts.zip
Invoke-WebRequest https://aka.ms/appsvconmasinstaller -OutFile AppService.exe

# Set Deployment Variables
$RGName = "App_Service_FS_RG"
$myLocation = "local"
$Password = "Passw0rd"
$Pass = ("$Password" | ConvertTo-SecureString -AsPlainText -Force)

$parameters = @{}
$parameters.Add(“fileshareOwnerPassword”,$Pass)
$parameters.Add(“fileshareUserPassword”,$Pass)
$parameters.Add(“AdminPassword”,$Pass)
$parameters.Add(“fileServerVirtualMachineSize”,"Standard_A3")

# Create Resource Group for Template Deployment
New-AzureRmResourceGroup -Name $RGName -Location $myLocation
# Deploy FS Template
New-AzureRmResourceGroupDeployment `
    -Name "$($RGName)_Deployment" `
    -ResourceGroupName $RGName `
    -TemplateUri https://raw.githubusercontent.com/Azure/AzureStack-QuickStart-Templates/master/appservice-fileserver-standalone/azuredeploy.json `
    -TemplateParameterObject $parameters 
$TenantArmEndpoint = "management.local.azurestack.external"
$AdminArmEndpoint = "adminmanagement.local.azurestack.external"


.\AppServiceHelperScripts\Create-AppServiceCerts.ps1 -PfxPassword $Pass -DomainName "local.azurestack.external"
.\Get-AzureStackRootCert.ps1 -PrivilegedEndpoint "AzS-ERCS01" -CloudAdminCredential $cred

# Requires Azure Login Credentials  
.\Create-AADIdentityApp.ps1 -DirectoryTenantName $TenantName -AdminArmEndpoint $AdminArmEndpoint `
    -TenantArmEndpoint $TenantArmEndpoint -CertificateFilePath (join-path (get-location).Path "sso.appservice.local.azurestack.external.pfx") -CertificatePassword $Pass
Set-Location C:\Temp\AppService\
Start-Process ".\AppService.exe" -ArgumentList "/logfile c:\temp\Appservice\appservice.log" -Wait