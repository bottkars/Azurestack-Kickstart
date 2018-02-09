#./bin/bash
sudo yum install git pigz docker ntp firewalld -y
sudo yum remove *nfs* -y
systemctl disable portmap

