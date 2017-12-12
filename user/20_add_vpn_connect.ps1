
#REQUIRES -RunAsAdministrator
winrm quickconfig -force -quiet

Set-ExecutionPolicy RemoteSigned

# Import the Connect module.
Import-Module "$($Global:AZSTools_location)/Connect/AzureStack.Connect.psm1"

# Add the development kit computer’s host IP address and certificate authority (CA) to the list of trusted hosts. Make sure you update the IP address and password values for your environment. 

$hostIP = $Global:StackIP

Set-Item wsman:\localhost\Client\TrustedHosts `
  -Value $hostIP `
  -Concatenate -Force 

Add-AzsVpnConnection `
  -ServerAddress $hostIP `
