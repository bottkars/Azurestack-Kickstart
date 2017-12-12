Start-Process "sc" -ArgumentList "config wuauserv start=disabled" -Wait -NoNewWindow
