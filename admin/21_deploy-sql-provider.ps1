$SQL_DIR = 'C:\TEMP\SQLRP'
Remove-Item $tempDir -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
$Uri = "https://aka.ms/azurestacksqlrp"
$Dir = New-Item -ItemType Directory $SQL_DIR -Force
Set-Location $SQL_DIR
$SQL_RP_URI = (Invoke-WebRequest -UseBasicParsing -MaximumRedirection 0 $Uri -ErrorAction SilentlyContinue).links.href
Start-BitsTransfer $SQL_RP_URI
$SQL_RP_FILE = Split-Path -Leaf $SQL_RP_URI
Start-Process "./$SQL_RP_FILE" -ArgumentList "-s" -Wait
$vmLocalAdminPass = ConvertTo-SecureString "$Global:VMPassword" -AsPlainText -Force
$vmLocalAdminCreds = New-Object System.Management.Automation.PSCredential ("sqlrpadmin",$vmLocalAdminPass )
$PfxPass = ConvertTo-SecureString $Global:VMPassword -AsPlainText -Force
.\DeploySQLProvider.ps1 -AzCredential $Global:ServiceAdminCreds `
  -VMLocalCredential $vmLocalAdminCreds `
  -CloudAdminCredential $Global:cloudAdminCreds `
  -PrivilegedEndpoint $global:privilegedEndpoint `
  -DefaultSSLCertificatePassword $PfxPass `
  -DependencyFilesLocalPath .\cert
