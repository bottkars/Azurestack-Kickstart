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

$Global:VMPassword = $Admin_Defaults.VMPassword
$Global:TenantName = $Admin_Defaults.TenantName
$Global:ServiceAdmin = "$($Admin_Defaults.serviceuser)@$Global:TenantName"
$Global:AZSTools_location = $Admin_Defaults.AZSTools_Location
$Global:subscriptionID = $Admin_Defaults.subscriptionID
$Global:subscriptionOwner = $Admin_Defaults.SubscriptionOwner
$Global:CloudAdmin = "$($Admin_Defaults.Domain)\$($Admin_Defaults.Cloudadmin)"
$Global:PrivilegedEndpoint = $Admin_Defaults.PrivilegedEndpoint
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
# For Azure Stack development kit, this value is set to https://adminmanagement.local.azurestack.external. To get this value for Azure Stack integrated systems, contact your service provider.
$Global:ArmEndpoint = $Admin_Defaults.ArmEndpoint
# For Azure Stack development kit, this value is adminvault.local.azurestack.external 
$Global:KeyvaultDnsSuffix = $Admin_Defaults.KeyvaultDnsSuffix

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
