<#
appservice.exe /quiet /log <log-file> Install
    appservice.exe /quiet /log <log-file> CreateOfflineInstallationPackage OfflineInstallationPackageFile=<zip-file>
    appservice.exe /quiet /log <log-file> Install OfflineInstallationPackageFile=<zip-file>
    appservice.exe /quiet /log <log-file> Deploy UserName=<UserName>Password=<Password> ParamFile=<parameter-file>
    appservice.exe /help
    appservice.exe /?

#>

param(# Set Deployment Variables
$RGName = "rg_App_Service_FS",
$myLocation = $Global:AZS_Location,
[securestring]$FilesharePassword = $Global:VMPassword,
[securestring]$PfxPassword = $Global:VMPassword,
$PrivilegedEndpoint = $Global:PrivilegedEndpoint,
[switch]$NoFileserverDeployment,
[switch]$NoOfflineDownload,
$Offlinepath = "$Home\Downloads\AppService"
)
if (!$Global:SubscriptionID)
    {
    Write-Warning -Message "You Have not Configured a SubscriptionID, did you run 99_bootstrap.ps1 ?"
    break
}
if ($Subscription = Get-AzureRmSubscription -SubscriptionName "Consumption Subscription")
  {
  Write-Host "Setting Environment to Consumption Subscription"
  Select-AzureRmSubscription -Subscription $Subscription  
  }
#Requires -Runas
Push-Location
Remove-item  C:\Temp\AppService -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
$Location = new-item -ItemType Directory C:\Temp\AppService -Force -ErrorAction SilentlyContinue
Set-Location $Location
Invoke-WebRequest https://aka.ms/appsvconmashelpers -OutFile AppServiceHelperScripts.zip
Expand-Archive AppServiceHelperScripts.zip
Invoke-WebRequest https://aka.ms/appsvconmasinstaller -OutFile AppService.exe

if (!(test-path $Offlinepath))
    {
        New-Item -ItemType Directory -Path $Offlinepath -Force | Out-Null
    }

if (!$NoFileserverDeployment.IsPresent)
    {
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
    }
$TenantArmEndpoint = split-path -Leaf $Global:TenantArmEndpoint
$AdminArmEndpoint = split-path -Leaf $Global:ArmEndpoint

Set-Location "C:\Temp\AppService\AppServiceHelperScripts\"

.\Create-AppServiceCerts.ps1 -PfxPassword $PfxPassword -DomainName "$($Global:AZS_Location).$($Global:DNSDomain)"
.\Get-AzureStackRootCert.ps1 -PrivilegedEndpoint $PrivilegedEndpoint -CloudAdminCredential $Global:CloudAdminCreds

# Requires Azure Login Credentials  
.\Create-AADIdentityApp.ps1 -DirectoryTenantName $Global:Tenantname `
 -AdminArmEndpoint $AdminArmEndpoint `
 -TenantArmEndpoint $TenantArmEndpoint `
 -CertificateFilePath (join-path (get-location).Path "sso.appservice.$($Global:AZS_Location).$($Global:DNSDomain).pfx") `
 -CertificatePassword $PfxPassword
Set-Location C:\Temp\AppService\
if (!$NoOfflineDownload.IsPresent)
    {
        Write-Host -ForegroundColor White "[==>]Downloading AppService Offline Package, please be patient"
        Start-Process ".\AppService.exe" -ArgumentList "/quiet /logfile c:\temp\Appservice\appservice.log  CreateOfflineInstallationPackage OfflineInstallationPackageFile=$($Offlinepath)\appservice.zip" -Wait
        Write-Host -ForegroundColor Green "[Done]"
    }
Pop-Location