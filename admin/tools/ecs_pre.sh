#./bin/bash
yum install git pigz docker ntp firewalld -y
yum remove *nfs* -y
systemctl disable rpcbind
shutdown -r now


