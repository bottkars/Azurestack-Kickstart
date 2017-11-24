
New-Item -ItemType Directory C:\Temp\MySQL -Force
Set-Location C:\Temp\MySQL
$MYSQL_RP_URI = (Invoke-WebRequest -UseBasicParsing -MaximumRedirection 0 https://aka.ms/azurestackmysqlrp -ErrorAction SilentlyContinue).links.href
Start-BitsTransfer $MYSQL_RP_URI

$MYSQL_RP_FILE = Split-Path -Leaf $MYSQL_RP_URI
Start-Process "./$MYSQL_RP_FILE" -ArgumentList "-s" -Wait

