#!/bin/bash
yum update -y 2>> /root/install.log  
yum install firewalld libselinux-python -y 2>> /root/install.log  
yum remove *nfs* -y 2>> /root/install.log  
systemctl disable rpcbind 2>> /root/install.log  
echo $?
