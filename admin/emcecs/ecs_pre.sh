#!/bin/bash
yum firewalld -y
yum remove *nfs* -y
systemctl disable rpcbind
exit 0
