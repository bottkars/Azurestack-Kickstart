param (
[securestring]$MySQLRPPassword = $Global:VMPassword,
[securestring]$PfxPass = $Global:VMPassword,
$MySQLRPadmin = $Global:MySQLRPAdmin
)
if (!$Global:SubscriptionID)
    {
    Write-Warning -Message "You Have not Configured a SubscriptionID, did you run 99_bootstrap.ps1 ?"
    break
}
push-location
$MYSQL_DIR = "C:\Temp\MySQL"
Remove-Item $MYSQL_DIR -Force -Recurse -ErrorAction SilentlyContinue -Confirm:$false | out-null
New-Item -ItemType Directory $MYSQL_DIR -Force
Set-Location $MYSQL_DIR
$MYSQL_RP_URI = (Invoke-WebRequest -UseBasicParsing -MaximumRedirection 0 https://aka.ms/azurestackmysqlrp -ErrorAction SilentlyContinue).links.href
Start-BitsTransfer $MYSQL_RP_URI

$MYSQL_RP_FILE = Split-Path -Leaf $MYSQL_RP_URI
Start-Process "./$MYSQL_RP_FILE" -ArgumentList "-s" -Wait

$vmLocalAdminCreds = New-Object System.Management.Automation.PSCredential ($MySQLRPadmin, $MySQLRPPassword)

.\DeployMySQLProvider.ps1 `
  -VMLocalCredential $vmLocalAdminCreds `
  -CloudAdminCredential $Global:cloudAdminCreds `
  -PrivilegedEndpoint $GLobal:PrivilegedEndpoint `
  -DefaultSSLCertificatePassword $PfxPass -DependencyFilesLocalPath .\cert `
  -AcceptLicense -Azcredential $Global:ServiceAdminCreds

Pop-Location
Write-Host -ForegroundColor Magenta "Please create your MYSQL SKU now from the Admin Portal before continue ( default is `"mysql57`")"