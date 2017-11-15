$cred = Get-Credential -Message 'enter cloudadmin password' -UserName "azurestack\cloudadmin"

  Enter-PSSession -ComputerName azs-ercs01 -ConfigurationName PrivilegedEndpoint -Credential $cred
