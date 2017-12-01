$sql_hostname = 'sqlhost1'
$rppassword = "Passw0rd"
$templateuri = 'https://raw.githubusercontent.com/Azure/AzureStack-QuickStart-Templates/master/sql-2014-standalone/azuredeploy.json'
$vmLocalAdminPass = ConvertTo-SecureString "$rppassword" -AsPlainText -Force 
$vmLocalAdminCreds = New-Object System.Management.Automation.PSCredential ("sqlrpadmin", $vmLocalAdminPass) 
$PfxPass = ConvertTo-SecureString "$rppassword" -AsPlainText -Force 

New-AzureRmResourceGroup -Name "rg_$sql_hostname" -Location local 
New-AzureRmResourceGroupDeployment -Name "$($sql_hostname)_deployment" -vmName $sql_hostname -dnsNameForPublicIP $sql_hostname -ResourceGroupName "rg_$sql_hostname" -TemplateUri $templateuri -adminPassword $vmlocaladminpass -adminUsername "sqlrpadmin" -windowsOSVersion "2016-Datacenter" -Mode Incremental -Verbose 