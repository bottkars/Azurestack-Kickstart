param(# Set Deployment Variables
$RGName = "rg_App_Service_FS",
$myLocation = $Global:AZS_Location,
[securestring]$FilesharePassword = $Global:VMPassword,
[securestring]$PfxPassword = $Global:VMPassword,
$PrivilegedEndpoint = $Global:PrivilegedEndpoint

)
Push-Location
Remove-item  C:\Temp\AppService -Force -Recurse -Confirm:$false
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

.\Create-AppServiceCerts.ps1 -PfxPassword $PfxPassword -DomainName "$($Global:AZS_Location).$($Global:DNSDomain)"
.\Get-AzureStackRootCert.ps1 -PrivilegedEndpoint $PrivilegedEndpoint -CloudAdminCredential $Global:CloudAdminCreds

# Requires Azure Login Credentials  
.\Create-AADIdentityApp.ps1 -DirectoryTenantName $Global:ArmEndpoint `
 -AdminArmEndpoint $AdminArmEndpoint `
 -TenantArmEndpoint $TenantArmEndpoint `
 -CertificateFilePath (join-path (get-location).Path "sso.appservice.$($Global:AZS_Location).$($Global:DNSDomain).pfx") `
 -CertificatePassword $PfxPassword
Set-Location C:\Temp\AppService\
Start-Process ".\AppService.exe" -ArgumentList "/logfile c:\temp\Appservice\appservice.log" -Wait
Pop-Location