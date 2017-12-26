param ()
$TMP_DIR = $HOME
$Uri = "https://aka.ms/InstallAzureCliWindows"
$MSI = (Invoke-WebRequest -UseBasicParsing -MaximumRedirection 0 $Uri -ErrorAction SilentlyContinue).links.href
Start-BitsTransfer $MSI -Description "Downloading AZCLI $MSI" -Destination "$HOME/Downloads"
Start-Process "msiexec" -ArgumentList "/i $Home/Downloads/$MSI /passive" -Wait




az ad app create --display-name "Service Principal for BOSH" \
--password "Password123!" --homepage "http://BOSHAzureCPI" \
--identifier-uris "http://BOSHAzureCPI



