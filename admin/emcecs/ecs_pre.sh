#!/bin/bash
# yum update -y &>> /root/install.log 
myreboot () {
   sleep 25 
   shutdown -r now
} 
yum install firewalld libselinux-python docker ntp pigz -y  
yum remove *nfs* -y 
systemctl disable rpcbind 
myreboot &  
echo $?
