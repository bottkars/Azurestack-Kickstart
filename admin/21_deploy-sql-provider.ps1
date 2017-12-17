param (
[ValidatePattern("^[a-z][a-z0-9-]{1,61}[a-z0-9]$")]$sql_hostname = 'sqlhost1',
[securestring]$SQLRPPassword = $Global:VMPassword,
[securestring]$PfxPass = $Global:VMPassword,
$SQLRPadmin = $Global:SQLRPAdmin
)
    
$SQL_DIR = 'C:\TEMP\SQLRP'
Remove-Item $tempDir -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
$Uri = "https://aka.ms/azurestacksqlrp"
New-Item -ItemType Directory $SQL_DIR -Force | Out-Null
Set-Location $SQL_DIR
$SQL_RP_URI = (Invoke-WebRequest -UseBasicParsing -MaximumRedirection 0 $Uri -ErrorAction SilentlyContinue).links.href
Start-BitsTransfer $SQL_RP_URI
$SQL_RP_FILE = Split-Path -Leaf $SQL_RP_URI
Start-Process "./$SQL_RP_FILE" -ArgumentList "-s" -Wait
$vmLocalAdminCreds = New-Object System.Management.Automation.PSCredential ($SQLRPadmin,$SQLRPPassword )
$PfxPass = ConvertTo-SecureString $Global:VMPassword -AsPlainText -Force
.\DeploySQLProvider.ps1 -AzCredential $Global:ServiceAdminCreds `
  -VMLocalCredential $vmLocalAdminCreds `
  -CloudAdminCredential $Global:cloudAdminCreds `
  -PrivilegedEndpoint $global:privilegedEndpoint `
  -DefaultSSLCertificatePassword $PfxPass `
  -DependencyFilesLocalPath .\cert
