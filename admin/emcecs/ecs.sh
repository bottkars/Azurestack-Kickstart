#!/bin/bash
before_reboot(){
yum install git firewalld -y
systemctl disable rpcbind    
cp initafterreboot /etc/init.d/
chmod +X /etc/init.d/initafterreboot
chmod 755 /etc/init.d/initafterreboot
cp ecs.sh /root/
chmod +X /root/ecs.sh
chmod 755 /root/ecs.sh
git clone https://github.com/emcecs/ecs-communityedition /root/ECS-CommunityEdition
cp deploy.yml /root/ECS-CommunityEdition
cd /root/ECS-CommunityEdition
touch /var/run/rebooting-for-bootstrap
}

after_bootstrap(){
    cd /root/ECS-CommunityEdition
    /root/bin/step1
    /root/bin/step2
}

after_reboot(){
    ./bootstrap.sh -c ./deploy.yml -y
}

if [ -f /var/run/rebooting-for-bootstrap ]; then
    after_bootstrap
    rm /var/run/rebooting-for-updates
    chkconfig --remove initafterreboot
elif [ -f /var/run/rebooting-for-updates ]; then
    rm /var/run/rebooting-for-updates
    touch /var/run/rebooting-for-bootstrap
    after_reboot
else
    before_reboot
    touch /var/run/rebooting-for-updates
    chkconfig --add initafterreboot
fi
echo $?
