#!/bin/bash
before_reboot(){
yum install git firewalld -y |& tee -a /root/install.log
systemctl disable rpcbind    
cp ecs.sh /root/ |& tee -a /root/install.log
chmod +X /root/ecs.sh |& tee -a /root/install.log
chmod 755 /root/ecs.sh |& tee -a /root/install.log
cp ecs-installer.service /etc/systemd/system/ |& tee -a /root/install.log
systemctl daemon-reload |& tee -a /root/install.log
systemctl enable ecs-installer.service |& tee -a /root/install.log
git clone https://github.com/emcecs/ecs-communityedition /root/ECS-CommunityEdition |& tee -a /root/install.log
cp deploy.yml /root/ECS-CommunityEdition |& tee -a /root/install.log
myreboot & |& tee -a /root/install.log
echo $? |& tee -a /root/install.log
}
myreboot () {
   sleep 20 |& tee -a /root/install.log 
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

