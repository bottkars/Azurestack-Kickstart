#./bin/bash
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
touch /var/run/rebooting-for-updates
./bootstrap.sh -c ../deploy.yml
}

after_reboot(){
    cd /root/ECS-CommunityEdition
    /root/bin/step1
    /root/bin/step2
}

if [ -f /var/run/rebooting-for-updates ]; then
    after_reboot
    rm /var/run/rebooting-for-updates
    chkconfig --remove initafterreboot
else
    before_reboot
    touch /var/run/rebooting-for-updates
    chkconfig --add initafterreboot
fi
exit 0
