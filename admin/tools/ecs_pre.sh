#./bin/bash
sudo yum install pigz docker ntp firewalld -y
sudo yum remove *nfs* -y
systemctl disable portmap

