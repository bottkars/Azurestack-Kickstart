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
cd /root/ECS-CommunityEdition
echo $?
}

after_bootstrap(){
    cd /root/ECS-CommunityEdition
    /root/bin/step1
    /root/bin/step2
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
echo $?
