#!/bin/bash
# yum update -y &>> /root/install.log 
myreboot () {
   sleep 20 |& tee -a /root/install.log 
   shutdown -r now
} 
yum install firewalld libselinux-python -y |& tee -a /root/install.log  
yum remove *nfs* -y |& tee -a /root/install.log  
systemctl disable rpcbind |& tee -a /root/install.log
myreboot & |& tee -a /root/install.log   
echo $?
