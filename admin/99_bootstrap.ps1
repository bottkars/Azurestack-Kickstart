[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-dsc")]
param (
[Parameter(ParameterSetName = "1", Mandatory = $false,Position = 1)][ValidateScript({ Test-Path -Path $_ })]$Defaultsfile="$HOME/admin.json"
)
if (!(Test-Path $Defaultsfile))
{
    Write-Warning "$Defaultsfile file does not exist.please copy from admin.json.example"
    Break
}
else
    {
    Write-Host -ForegroundColor White "[==>]loading Admin Enviromment from $Defaultsfile" -NoNewline
    try {
        $Admin_Defaults = Get-Content $Defaultsfile | ConvertFrom-Json -ErrorAction SilentlyContinue   
    }
    catch {
        Write-Host "could not load $Defaultsfile, maybe a format error ?
        try validate at https://jsonlint.com/"
        break
    }
    Write-Host -ForegroundColor Green [Done]
    Write-Output $Admin_Defaults
    }
if (!$Admin_Defaults.VMPassword)
    {
       Write-Warning "VMpassword is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:VMPassword = $Admin_Defaults.VMPassword | ConvertTo-SecureString -AsPlainText -Force
if (!$Admin_Defaults.TenantName)
    {
       Write-Warning "TenantName is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }

$Global:TenantName = $Admin_Defaults.TenantName
if (!$Admin_Defaults.serviceuser)
    {
       Write-Warning "serviceuser is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:ServiceAdmin = "$($Admin_Defaults.serviceuser)@$Global:TenantName"
if (!$Admin_Defaults.AZSTools_Location)
    {
       Write-Warning "AZSTools_Location is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:AZSTools_location = $Admin_Defaults.AZSTools_Location
if (!$Admin_Defaults.subscriptionID)
    {
       Write-Warning "subscriptionID is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:subscriptionID = $Admin_Defaults.subscriptionID
if (!$Admin_Defaults.SubscriptionOwner)
    {
       Write-Warning "SubscriptionOwner is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:subscriptionOwner = $Admin_Defaults.SubscriptionOwner
if (!$Admin_Defaults.Cloudadmin)
    {
       Write-Warning "Cloudadmin is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:CloudAdmin = "$($Admin_Defaults.Domain)\$($Admin_Defaults.Cloudadmin)"
if (!$Admin_Defaults.PrivilegedEndpoint)
    {
       Write-Warning "PriviledgedEndpoint is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:PrivilegedEndpoint = $Admin_Defaults.PrivilegedEndpoint
if (!$Admin_Defaults.location)
    {
       Write-Warning "location is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:AZS_Location = $Admin_Defaults.location
if (!$Admin_Defaults.VMuser)
    {
       Write-Warning "VMuser is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:VMUser= $Admin_Defaults.VMuser
if (!$Admin_Defaults.SQLRPADMIN)
    {
       Write-Warning "SQLRPADMIN is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }

$Global:SQLRPadmin = $Admin_Defaults.SQLRPADMIN
if (!$Admin_Defaults.MySQLRPADMIN)
    {
       Write-Warning "MYSQLRPADMIN is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:MySQLRPadmin = $Admin_Defaults.MySQLRPADMIN

if (!$Admin_Defaults.SQLHost)
    {
       Write-Warning "SQLHOST is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }

$Global:SQLhost = $Admin_Defaults.SQLHost
if (!$Admin_Defaults.MySQLHost)
    {
       Write-Warning "MySQLHost is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:MySQLRPadmin = $Admin_Defaults.MySQLHost



if (!$Admin_Defaults.ArmEndpoint)
    {
       Write-Warning "ArmEndpoint is not set in $defaultsfile. Please add entry and retry
       For Azure Stack development kit, this value is set to https://adminmanagement.local.azurestack.external" 
       Break 
    }
$Global:ArmEndpoint = $Admin_Defaults.ArmEndpoint
if (!$Admin_Defaults.KeyvaultDnsSuffix)
    {
       Write-Warning "KeyvaultDnsSuffix is not set in $defaultsfile. Please add entry and retry
       For Azure Stack development kit, this value is adminvault.local.azurestack.external" 
       Break 
    }
$Global:KeyvaultDnsSuffix = $Admin_Defaults.KeyvaultDnsSuffix


if (!$Admin_Defaults.ISOPath)
    {
       Write-Warning "ISOpath is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:ISOPath = $Admin_Defaults.ISOpath

if (!$Admin_Defaults.UpdatePath)
    {
       Write-Warning "UpdatePath is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:UpdatePath= $Admin_Defaults.UpdatePath








#########
if (!$Global:ServiceAdminCreds)
    {
    $ServiceAdminCreds = Get-Credential -UserName $GLobal:serviceAdmin -Message "Enter Azure ServiceAdmin Password"
    }
if (!$Global:CloudAdminCreds)
    {
    $Global:CloudAdminCreds = Get-Credential -UserName $CloudAdmin -Message "Enter Azure CloudAdmin Password for $Cloudadmin" 
    }

$Modules = ("$($GLobal:AZSTools_location)\Connect\AzureStack.Connect.psm1",
    "$($Global:AZSTools_location)\serviceAdmin\AzureStack.ServiceAdmin.psm1",
    "$($Global:AZSTools_location)\ComputeAdmin\AzureStack.ComputeAdmin.psm1")
foreach ($module in $Modules)
    {
        Write-Host -ForegroundColor White "[==>]Importing Module $Module" -NoNewline
        Import-Module $Module -Force
        Write-Host -ForegroundColor Green [Done]
    }

# Register an AzureRM environment that targets your Azure Stack instance
Write-Host -ForegroundColor White "[==>]Registering AzureRM Environment for $ArmEndpoint" -NoNewline
$Global:AZS_RM_Environment = Add-AzureRMEnvironment `
    -Name "AzureStackAdmin" `
    -ArmEndpoint $ArmEndpoint
Write-Host -ForegroundColor Green [Done]

# Get the Active Directory tenantId that is used to deploy Azure Stack
  $Global:TenantID = Get-AzsDirectoryTenantId `
    -AADTenantName $TenantName `
    -EnvironmentName "AzureStackAdmin"

# Sign in to your environment


try {

 $Servive_RM_Account = Login-AzureRmAccount `
    -EnvironmentName "AzureStackAdmin" `
    -TenantId $TenantID -Credential $ServiceAdminCreds -ErrorAction Stop
}
catch  {
    write-host "could not login AzureRMAccount $($Global:ServiceAdmin), maybe wrong pasword ? "
    Break	
}
$Global:ServiceAdminCreds = $ServiceAdminCreds
$Global:Service_RM_Account = $Servive_RM_Account
