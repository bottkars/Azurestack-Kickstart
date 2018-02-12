#!/bin/bash
# yum update -y &>> /root/install.log 
myreboot () {
   sleep 20 
   shutdown -r now
} 
yum install firewalld libselinux-python -y  
yum remove *nfs* -y 
systemctl disable rpcbind 
myreboot &  
echo $?
