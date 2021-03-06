﻿[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-kickstart")]
param (
[Parameter(ParameterSetName = "1", Mandatory = $false,Position = 1)][ValidateScript({ Test-Path -Path $_ })]$Defaultsfile="$HOME/admin.json"
)
function test-pathvalid 
{
param (
    $path
    )
 
if (!(test-path $path))
    {
        try {
            $NewPath = New-Item -ItemType Directory -Path $path -Force -ErrorAction Stop
        }
        catch 			
        [System.Management.Automation.DriveNotfoundException] 
            {
                write-Host "Drive $(split-path -qualifier $path) was not found"
                Break
            }
        catch {
            Write-Warning "error creating Path $path "
            Break
        }
    }

}
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

write-host "[==>]Setting Endpoints" -NoNewline
if (!$Admin_Defaults.location)
    {
        Write-Warning "location is not set in $defaultsfile. Please add entry and retry" 
        Break 
    }
$Global:AZS_Location = $Admin_Defaults.location
if (!$Admin_Defaults.DNSDomain)
    {
        Write-Warning "DNSDomain is not set in $defaultsfile. Please add entry and retry" 
        Break 
    }
$Global:DNSDomain = $Admin_Defaults.DNSDomain
$Global:TenantArmEndpoint = "https://management.$($Global:AZS_Location).$($Global:DNSDomain)"
$Global:ArmEndpoint = "https://adminmanagement.$($Global:AZS_Location).$($Global:DNSDomain)"
$Global:KeyvaultDnsSuffix = "adminvault.$($Global:AZS_Location).$($Global:DNSDomain)"
$Global:GraphEndpoint = "https://graph.$($Global:AZS_Location).$($Global:DNSDomain)"
Write-Host -ForegroundColor Green "[Done]"
    

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
$Global:ServiceAdmin = $Admin_Defaults.serviceuser
if (!$Admin_Defaults.AZSTools_Location)
    {
       Write-Warning "AZSTools_Location is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:AZSTools_location = $Admin_Defaults.AZSTools_Location

if (!$Admin_Defaults.consumptionSubscription)
    {
    Write-Warning "consumptionSubscription is not set in $defaultsfile, you may want to add for future use. Using Default Provider Subscription now" 
    $Global:consumptionSubscription = "Default Provider Subscription"
    }
else {
    $Global:consumptionSubscription = $Admin_Defaults.consumptionSubscription
}


if (!$Admin_Defaults.meteringSubscription)
    {
       Write-Warning "meteringSubscription is not set in $defaultsfile, you may want to add for future use. Using Default Provider Subscription now" 
       $Global:meteringSubscription = "Default Provider Subscription"
    }
else {
        $Global:meteringSubscription = $Admin_Defaults.meteringSubscription
    }   

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
       Write-Warning "MySQLRPADMIN is not set in $defaultsfile. Please add entry and retry" 
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
$Global:MySQLHost = $Admin_Defaults.MySQLHost


if (!$Admin_Defaults.AzureRMVersion)
    {
       Write-Warning "AzureRMVersion is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:AzureRMVersion = $Admin_Defaults.AzureRMVersion

if (!$Admin_Defaults.AzureSTackModuleVersion)
    {
       Write-Warning "AzureSTackModuleVersion is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:AzureSTackModuleVersion = $Admin_Defaults.AzureSTackModuleVersion

if (!$Admin_Defaults.ISOPath)
    {
       Write-Warning "ISOpath is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:ISOPath = $Admin_Defaults.ISOpath
test-pathvalid $Admin_Defaults.ISOpath
if (!$Admin_Defaults.UpdatePath)
    {
       Write-Warning "UpdatePath is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:UpdatePath= $Admin_Defaults.UpdatePath
test-pathvalid $Admin_Defaults.UpdatePath
if (!$Admin_Defaults.ImagePath)
    {
       Write-Warning "ImagePath is not set in $defaultsfile. Please add entry and retry" 
       Break 
    }
$Global:ImagePath= $Admin_Defaults.ImagePath
test-pathvalid $Admin_Defaults.ImagePath


#########
if (!$Global:ServiceAdminCreds)
    {
        Write-Verbose "using "
    $ServiceAdminCreds = Get-Credential -UserName $GLobal:serviceAdmin -Message "Enter Azure ServiceAdmin Password"
    }
if (!$Global:CloudAdminCreds)
    {
    $Global:CloudAdminCreds = Get-Credential -UserName $CloudAdmin -Message "Enter Azure CloudAdmin Password for $Cloudadmin" 
    }
#"$($GLobal:AZSTools_location)\Connect\AzureStack.Connect.psm1",
$Modules = (
    "$($GLobal:AZSTools_location)\Connect\AzureStack.Connect.psm1"
    #"$($Global:AZSTools_location)\serviceAdmin\AzureStack.ServiceAdmin.psm1",
    #"$($Global:AZSTools_location)\ComputeAdmin\AzureStack.ComputeAdmin.psm1")
)
foreach ($module in $Modules)
    {
        Write-Host -ForegroundColor White "[==>]Importing Module $Module" -NoNewline
        Import-Module $Module -Force
        Write-Host -ForegroundColor Green [Done]
    }

# Register an AzureRM environment that targets your Azure Stack instance
Write-Host -ForegroundColor White "[==>]Registering AzureRM Environment for $ArmEndpoint" -NoNewline
$Global:AZS_RM_Environment = Add-AzEnvironment `
    -Name "AzureStackAdmin" `
    -ArmEndpoint $ArmEndpoint
Write-Host -ForegroundColor Green [Done]

# Get the Active Directory tenantId that is used to deploy Azure Stack
#  $Global:TenantID = Get-AzsDirectoryTenantId `
    # Set your tenant name
    $AuthEndpoint = (Get-AzEnvironment -Name "AzureStackAdmin").ActiveDirectoryAuthority.TrimEnd('/')

    $Global:TenantId = (invoke-restmethod "$($AuthEndpoint)/$($Global:TenantName)/.well-known/openid-configuration").issuer.TrimEnd('/').Split('/')[-1]

    # After signing in to your environment, Azure Stack Hub cmdlets
    # can be easily targeted at your Azure Stack Hub instance.
    Add-AzAccount -EnvironmentName "AzureStackAdmin" -TenantId $Global:TenantId
# Sign in to your environment

#Write-Host "Please login now with serviceaccount once"
#$test = Login-AzureRmAccount `
#    -EnvironmentName "AzureStackAdmin" `
#    -TenantId $Global:TenantID

try {
 Write-Verbose "using Tenant ID $($Global:TenantID)"
 $Service_RM_Account = Login-AzAccount `
    -EnvironmentName "AzureStackAdmin" `
    -TenantId $Global:TenantID -Credential $ServiceAdminCreds -ErrorAction Stop
}
catch  {
    write-host "could not login AzAccount $($Global:ServiceAdmin), maybe wrong pasword ? "
    Break	
}
$Global:ServiceAdminCreds = $ServiceAdminCreds
$Global:Service_RM_Account = $Service_RM_Account

$host.ui.RawUI.WindowTitle = "Logged in with  $($Global:Service_RM_Account.context.account) as $($Global:AZS_RM_Environment.Name) "    
