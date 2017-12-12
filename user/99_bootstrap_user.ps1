[CmdletBinding(HelpUri = "https://github.com/bottkars/azurestack-dsc")]
param (
[Parameter(ParameterSetName = "1", Mandatory = $false,Position = 1)][ValidateScript({ Test-Path -Path $_ })]$Defaultsfile="$HOME/user.json",
[switch]$noconnect
)
if (!(Test-Path $Defaultsfile))
{
    Write-Warning "$Defaultsfile file does not exist.please copy from user.json.example"
    Break
}
else
    {
    Write-Host -ForegroundColor Gray " ==>loading Admin Enviromment from $Defaultsfile"
    try {
        $User_Defaults = Get-Content $Defaultsfile | ConvertFrom-Json -ErrorAction SilentlyContinue   
    }
    catch {
        Write-Host "could not load $Defaultsfile, maybe a format error ?"
        break
    }
    
    Write-Output $User_Defaults
    }

$Global:azsuser = $User_Defaults.azsuser
$Global:TenantName = $User_Defaults.TenantName
$global:azsuseraccount = "$Global:azsuser@$Global:TenantName"
$global:AZS_MODULES_ROOT = $User_Defaults.AZSTools_Location
if (!$azsuser_credentials)
    {
    $azsuser_credentials = Get-Credential -Message "Enter Azure User Password for $global:azsuser" -UserName $global:azsuseraccount
    }
Import-Module AzureRM.AzureStackAdmin
Import-Module "$global:AZS_MODULES_ROOT\Connect\AzureStack.Connect.psm1"
$Global:ArmEndpoint = $User_Defaults.ArmEndpoint
$Global:GraphAudience = $User_Defaults.GraphAudience
$Global:StackIP = $User_Defaults.StackIP


if (!$noconnect.IsPresent)
    {
    Add-AzureRMEnvironment `
      -Name "AzureStackUser" `
      -ArmEndpoint $Global:ArmEndpoint
    
    Set-AzureRmEnvironment `
      -Name "AzureStackUser" `
      -GraphAudience $Global:GraphAudience
    
    $Global:TenantID = Get-AzsDirectoryTenantId `
      -AADTenantName "$Global:TenantName" `
      -EnvironmentName "AzureStackUser"      
    try {
      Login-AzureRmAccount `
      -EnvironmentName "AzureStackUser" `
      -TenantId $Global:TenantID `
      -Credential $global:azsuser_credentials `
      -ErrorAction stop
    }
    catch {
      Write-Host "Could not Login with $($Global:azsuser)
      Maybe not connected to Stack or wrong password ?"  

    }
    $global:azsuser_credentials  = $azsuser_credentials
    }
