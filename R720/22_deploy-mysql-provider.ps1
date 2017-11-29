Set-AzureRmEnvironment -Name AzureStackAdmin -GraphAudience https://graph.windows.net/

$MYSQL_DIR = "C:\Temp\MySQL"
Remove-Item $MYSQL_DIR -Force -Recurse -ErrorAction SilentlyContinue -Confirm:$false
New-Item -ItemType Directory $MYSQL_DIR -Force
Set-Location $MYSQL_DIR
$MYSQL_RP_URI = (Invoke-WebRequest -UseBasicParsing -MaximumRedirection 0 https://aka.ms/azurestackmysqlrp -ErrorAction SilentlyContinue).links.href
Start-BitsTransfer $MYSQL_RP_URI

$MYSQL_RP_FILE = Split-Path -Leaf $MYSQL_RP_URI
Start-Process "./$MYSQL_RP_FILE" -ArgumentList "-s" -Wait

$vmLocalAdminPass = ConvertTo-SecureString "P@ssw0rd1" -AsPlainText -Force
$vmLocalAdminCreds = New-Object System.Management.Automation.PSCredential ("mysqlrpadmin", $vmLocalAdminPass)
$PfxPass = ConvertTo-SecureString "P@ssw0rd1" -AsPlainText -Force

.\DeployMySQLProvider.ps1 `
  -VMLocalCredential $vmLocalAdminCreds `
  -CloudAdminCredential $cloudAdminCreds `
  -PrivilegedEndpoint 'AZS-ERCS01' `
  -DefaultSSLCertificatePassword $PfxPass -DependencyFilesLocalPath .\cert `
  -AcceptLicense -Azcredential $AdminCreds




New-AzureRmResourceGroup -Name MySQL-Host -Location local 

New-AzureRmResourceGroupDeployment -Name Mysqlhost1 -ResourceGroupName MySQL-Host `
    -vmName MySQLHost1 `
    -TemplateUri https://raw.githubusercontent.com/Azure/AzureStack-QuickStart-Templates/master/mysql-standalone-server-windows/azuredeploy.json `
    -adminPassword $vmlocaladminpass -adminUsername "mysqlrpadmin" -windowsOSVersion "2016-Datacenter" -Mode Incremental -vmSize Standard_A4 -Verbose 




