#./bin/bash
yum install git pigz docker ntp firewalld -y
yum remove *nfs* -y
systemctl disable rpcbind
echo "${1}"

if  [ "${1}" == "reboot" ];then
        shutdown -r now
else
    sh ./ecs.sh
fi



