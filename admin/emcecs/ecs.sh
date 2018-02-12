#!/bin/bash
before_reboot(){
yum install git firewalld -y 2>> /root/install.log
systemctl disable rpcbind    
cp ecs.sh /root/ 2>> /root/install.log
chmod +X /root/ecs.sh 2>> /root/install.log
chmod 755 /root/ecs.sh 2>> /root/install.log
cp ecs-installer.service /etc/systemd/system/ 2>> /root/install.log
systemctl daemon-reload 2>> /root/install.log
systemctl enable ecs-installer.service 2>> /root/install.log
git clone https://github.com/emcecs/ecs-communityedition /root/ECS-CommunityEdition 2>> /root/install.log
cp deploy.yml /root/ECS-CommunityEdition 2>> /root/install.log
myreboot & 2>> /root/install.log
echo $? 2>> /root/install.log
}
myreboot () {
   sleep 20 2>> /root/install.log 
   shutdown -r now
} 
after_bootstrap(){
    cd /root/ECS-CommunityEdition
    /root/bin/step1 2>> /root/install.log
    /root/bin/step2 2>> /root/install.log
}

after_waagent(){
    cd /root/ECS-CommunityEdition   
    ./bootstrap.sh -c ./deploy.yml -y
}

if [ -f /var/run/rebooting-for-bootstrap ]; then
    after_bootstrap
    rm /var/run/rebooting-for-bootstrap
    systemctl disable ecs-installer.service
elif [ -f /var/run/rebooting-for-waagent ]; then
    rm /var/run/rebooting-for-waagent
    touch /var/run/rebooting-for-bootstrap
    after_waagent
else
    touch /var/run/rebooting-for-waagent
    before_reboot
fi

