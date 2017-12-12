$domain = "AzureStack"
$prefix = "AzS"
$privilegedEndpoint = "$prefix-ERCS01"
$Global:VMPassword = "Regen2017+"

# Point to the directory where the RP installation files were extracted
$SQL_DIR = 'C:\TEMP\SQLRP'
Remove-Item $tempDir -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
$Uri = "https://aka.ms/azurestacksqlrp"
$Dir = New-Item -ItemType Directory $SQL_DIR -Force
Set-Location $SQL_DIR
$SQL_RP_URI = (Invoke-WebRequest -UseBasicParsing -MaximumRedirection 0 $Uri -ErrorAction SilentlyContinue).links.href
Start-BitsTransfer $SQL_RP_URI
$SQL_RP_FILE = Split-Path -Leaf $SQL_RP_URI
Start-Process "./$SQL_RP_FILE" -ArgumentList "-s" -Wait


# The service admin account (can be AAD or ADFS)


# Set the credentials for the Resource Provider VM
$vmLocalAdminPass = ConvertTo-SecureString "$Global:VMPassword" -AsPlainText -Force
$vmLocalAdminCreds = New-Object System.Management.Automation.PSCredential ("sqlrpadmin",$vmLocalAdminPass )


# change the following as appropriate
$PfxPass = ConvertTo-SecureString $Global:VMPassword -AsPlainText -Force

# Change directory to the folder where you extracted the installation files
# and adjust the endpoints
.\DeploySQLProvider.ps1 -AzCredential $Global:ServiceAdminCreds `
  -VMLocalCredential $vmLocalAdminCreds `
  -CloudAdminCredential $Global:cloudAdminCreds `
  -PrivilegedEndpoint $privilegedEndpoint `
  -DefaultSSLCertificatePassword $PfxPass `
  -DependencyFilesLocalPath .\cert
