param ()
$TMP_DIR = $HOME
$Uri = "https://aka.ms/InstallAzureCliWindows"
$MSI = (Invoke-WebRequest -UseBasicParsing -MaximumRedirection 0 $Uri -ErrorAction SilentlyContinue).links.href
Start-BitsTransfer $MSI -Description "Downloading AZCLI $MSI" -Destination "$HOME/Downloads"
Start-Process "msiexec" -ArgumentList "/i $Home/Downloads/$MSI /passive" -Wait
<#
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
Pop-Location
#>