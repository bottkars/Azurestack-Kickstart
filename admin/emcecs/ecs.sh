#!/bin/bash
before_reboot(){
yum install git firewalld -y 
systemctl disable rpcbind    
cp ecs.sh /root/ 
chmod +X /root/ecs.sh 
chmod 755 /root/ecs.sh 
cp ecs-installer.service /etc/systemd/system/ 
systemctl daemon-reload 
systemctl enable ecs-installer.service 
git clone https://github.com/emcecs/ecs-communityedition /root/ECS-CommunityEdition 
cp deploy.yml /root/ECS-CommunityEdition 
myreboot & 
echo $? 
}
myreboot () {
   sleep 20  
   shutdown -r now
} 
after_bootstrap(){
    cd /root/ECS-CommunityEdition
    /root/bin/step1 |& tee -a /root/install.log
    /root/bin/step2 |& tee -a /root/install.log
}

after_waagent(){
    cd /root/ECS-CommunityEdition   
    ./bootstrap.sh -c ./deploy.yml -y
}

if [ -f /root/rebooting-for-bootstrap ]; then
    after_bootstrap
    rm /root/rebooting-for-bootstrap
    systemctl disable ecs-installer.service
elif [ -f /root/rebooting-for-waagent ]; then
    rm /root/rebooting-for-waagent
    touch /root/rebooting-for-bootstrap
    after_waagent
else
    touch /root/rebooting-for-waagent
    before_reboot
fi

