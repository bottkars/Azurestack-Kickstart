$Netadapter = Get-NetAdapter | where macaddress -Match "00-0A-F7-41-0D-42" 
$Netadapter | Enable-NetAdapter
$Netadapter | New-NetIPAddress 10.204.16.82 -PrefixLength 27 -AddressFamily IPv4

$allnics = Get-NetAdapter | where MacAddress -Match 'C8-1F-66-D4-67'

foreach ($Nic in $allnics)
    {
        $Nic | Enable-NetAdapter
    }
$IP = Get-NetIPAddress | where ipaddress -match '172.21.20'
$IP | New-NetIPAddress -PrefixLength 24 -IPAddress 172.21.6.166 
