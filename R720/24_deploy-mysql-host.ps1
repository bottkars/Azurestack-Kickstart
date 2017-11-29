New-AzureRmResourceGroup -Name MySQL-Host_RG -Location local 

New-AzureRmResourceGroupDeployment -Name Mysqlhost1 -ResourceGroupName MySQL-Host_RG `
    -vmName MySQLHost1 `
    -TemplateUri https://raw.githubusercontent.com/Azure/AzureStack-QuickStart-Templates/master/mysql-standalone-server-windows/azuredeploy.json `
    -adminPassword $vmlocaladminpass -adminUsername "mysqlrpadmin" -windowsOSVersion "2016-Datacenter" -Mode Incremental -vmSize Standard_A4 -Verbose 



New-AzureRmResourceGroup -Name MySQLHostingserver_RG -Location local 

New-AzureRmResourceGroupDeployment -Name MySQLHostingserver_Deploy -ResourceGroupName MySQLHostingserver_RG `
    -TemplateUri https://raw.githubusercontent.com/Azure/AzureStack-QuickStart-Templates/master/101-mysqladapter-add-hosting-server/azuredeploy.json `
    -HostingServerName MySQLHost1 -password $vmlocaladminpass -username "mysqlrpadmin" -Mode Incremental -totalSpaceMB 102400 -skuName mysql57 -Verbose 


