#!/bin/bash
before_reboot(){
yum install git firewalld -y &>> /root/install.log
systemctl disable rpcbind    
cp ecs.sh /root/ &>> /root/install.log
chmod +X /root/ecs.sh &>> /root/install.log
chmod 755 /root/ecs.sh &>> /root/install.log
cp ecs-installer.service /etc/systemd/system/ &>> /root/install.log
systemctl daemon-reload &>> /root/install.log
systemctl enable ecs-installer.service &>> /root/install.log
git clone https://github.com/emcecs/ecs-communityedition /root/ECS-CommunityEdition &>> /root/install.log
cp deploy.yml /root/ECS-CommunityEdition &>> /root/install.log
echo $? &>> /root/install.log
}

after_bootstrap(){
    cd /root/ECS-CommunityEdition
    /root/bin/step1 &>> /root/install.log
    /root/bin/step2 &>> /root/install.log
}

after_reboot(){
    cd /root/ECS-CommunityEdition   
    ./bootstrap.sh -c ./deploy.yml -y
}

if [ -f /var/run/rebooting-for-bootstrap ]; then
    after_bootstrap
    rm /var/run/rebooting-for-bootstrap
    systemctl disable ecs-installer.service
elif [ -f /var/run/rebooting-for-updates ]; then
    rm /var/run/rebooting-for-updates
    touch /var/run/rebooting-for-bootstrap
    after_reboot
else
    touch /var/run/rebooting-for-updates
    before_reboot
fi

