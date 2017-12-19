param(# Set Deployment Variables
$RGName = "rg_App_Service_FS",
$myLocation = $Global:AZS_Location,
[securestring]$FilesharePassword = $Global:VMPassword
)
Push-Location
$Location = new-item -ItemType Directory C:\Temp\AppService -Force
Set-Location $Location
Invoke-WebRequest https://aka.ms/appsvconmashelpers -OutFile AppServiceHelperScripts.zip
Expand-Archive AppServiceHelperScripts.zip
Invoke-WebRequest https://aka.ms/appsvconmasinstaller -OutFile AppService.exe



$parameters = @{}
$parameters.Add("fileshareOwnerPassword",$FilesharePassword)
$parameters.Add("fileshareUserPassword",$FilesharePassword)
$parameters.Add("AdminPassword",$FilesharePassword)
$parameters.Add("fileServerVirtualMachineSize","Standard_A3")

# Create Resource Group for Template Deployment
New-AzureRmResourceGroup -Name $RGName -Location $myLocation
# Deploy FS Template
New-AzureRmResourceGroupDeployment `
    -Name "$($RGName)_Deployment" `
    -ResourceGroupName $RGName `
    -TemplateUri https://raw.githubusercontent.com/Azure/AzureStack-QuickStart-Templates/master/appservice-fileserver-standalone/azuredeploy.json `
    -TemplateParameterObject $parameters `
    -Verbose
$TenantArmEndpoint = split-path -Leaf $Global:TenantArmEndpoint
$AdminArmEndpoint = split-path -Leaf $Global:ArmEndpoint

Set-Location "C:\Temp\AppService\AppServiceHelperScripts\"

.\Create-AppServiceCerts.ps1 -PfxPassword $Pass -DomainName "local.azurestack.external"
.\Get-AzureStackRootCert.ps1 -PrivilegedEndpoint "AzS-ERCS01" -CloudAdminCredential $Global:CloudAdminCreds

# Requires Azure Login Credentials  
.\Create-AADIdentityApp.ps1 -DirectoryTenantName $TenantName `
 -AdminArmEndpoint $AdminArmEndpoint `
 -TenantArmEndpoint $TenantArmEndpoint `
 -CertificateFilePath (join-path (get-location).Path "sso.appservice.local.azurestack.external.pfx") `
 -CertificatePassword $Pass
Set-Location C:\Temp\AppService\
Start-Process ".\AppService.exe" -ArgumentList "/logfile c:\temp\Appservice\appservice.log" -Wait
Pop-Location