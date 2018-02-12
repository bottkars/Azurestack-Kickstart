#!/bin/bash
# yum update -y &>> /root/install.log 
myreboot () {
   sleep 20 2>> /root/install.log 
   shutdown -r now
} 
yum install firewalld libselinux-python -y 2>> /root/install.log  
yum remove *nfs* -y 2>> /root/install.log  
systemctl disable rpcbind 2>> /root/install.log
myreboot & &>> /root/install.log   
echo $?
