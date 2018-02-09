#./bin/bash
before_reboot(){
yum install git pigz docker ntp firewalld -y
yum remove *nfs* -y
systemctl disable rpcbind    
cp initafterreboot /etc/init.d/
cp ecs.sh /root/
git clone https://github.com/emcecs/ecs-communityedition
cd ecs-communityedition
./bootstrap.sh -c ../deploy.yml
}

after_reboot(){
    step1
    step2
}

if [ -f /var/run/rebooting-for-updates ]; then
    after_reboot
    rm /var/run/rebooting-for-updates
    update-rc.d initafterreboot remove
else
    before_reboot
    touch /var/run/rebooting-for-updates
    update-rc.d initafterreboot defaults
fi
exit 0
