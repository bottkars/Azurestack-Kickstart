#!/bin/bash
# yum update -y &>> /root/install.log  
yum install firewalld libselinux-python -y &>> /root/install.log  
yum remove *nfs* -y &>> /root/install.log  
systemctl disable rpcbind &>> /root/install.log  
echo $?
