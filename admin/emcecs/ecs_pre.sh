#!/bin/bash
# yum update -y &>> /root/install.log 
myreboot () {
   sleep 60 
   shutdown -r now
} 
yum install firewalld libselinux-python docker ntp pigz python-docker-py -y  
yum remove *nfs* -y 
systemctl disable rpcbind 
myreboot &  
echo $?
