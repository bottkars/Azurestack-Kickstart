#!/bin/bash
yum install firewalld libselinux-python -y
yum remove *nfs* -y
systemctl disable rpcbind
echo $?
