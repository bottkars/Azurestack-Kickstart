#!/bin/bash
edit_template(){

chars=( {c..z} )
n=$1
for ((i=0; i<n; i++))
do
    disks[i]="\/dev\/sd${chars[i]}"
done
disklist="$(echo "'${disks[*]}'" | tr ' ' ,)"
disklist="${disklist//","/"','"}"
echo "replacing mydisks with disklist $disklist" >> /root/install.log
sed -i -e 's/mydisks/'"$disklist"'/g' /root/ECS-CommunityEdition/deploy.yml

n=$2
for ((i=1; i<=n; i++))
do
    hosts[i]=$3$i
done
hostlist="$(echo "'${hosts[*]}'" | tr ' ' ,)"
hostlist="${hostlist//","/"','"}"
echo "replacing myhosts with hostlist $hostlist" >> /root/install.log
sed -i -e 's/myhosts/'"$hostlist"'/g' /root/ECS-CommunityEdition/deploy.yml

n=$2
for ((i=4; i<=n+3; i++))
do
    members[i]=10.0.0.$i
done
memberlist="$(echo "'${members[*]}'" | tr ' ' ,)"
memberlist="${memberlist//","/"','"}"
echo "replacing mymembers with memberlist $memberlist" >> /root/install.log
sed -i -e 's/mymembers/'"$memberlist"'/g' /root/ECS-CommunityEdition/deploy.yml
}
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
echo "$1 $2 $3" >> /root/parameters.txt
edit_template $1 $2 $3
myreboot & 
echo $? 
}
myreboot () {
   sleep 25  
   shutdown -r now
} 
after_bootstrap(){
    cd /root/ECS-CommunityEdition
    /usr/bin/step1 |& tee -a /root/install.log
    /usr/bin/step2 |& tee -a /root/install.log
    echo "done" |& tee -a /root/install.log
}

after_waagent(){
    cd /root/ECS-CommunityEdition   
    ./bootstrap.sh -c ./deploy.yml -y |& tee -a /root/install.log
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

