#!/bin/bash

MINE=https://raw.githubusercontent.com/jsEveryDay/CentOS-Config/master/setup

read -p 'User: ' myUser
read -p 'Pass: ' myPass
read -p 'Domain: ' myDomain

sed -i '$ a alias mycron="env EDITOR=nano crontab -e"' $HOME/.bashrc
sed -i '$ a alias tara="tar cvzf"' $HOME/.bashrc
sed -i '$ a alias tarx="tar -zxvf"' $HOME/.bashrc
sed -i '$ a alias mynginx="cd /usr/local/apps/nginx/etc/conf.d"' $HOME/.bashrc
sed -i '$ a alias myip="wget -qO- http://ipecho.net/plain ; echo"' $HOME/.bashrc

ip=$(cat ip.php) 

#----------------------------------
# Setup VirtualEnv and PIP for C9
#----------------------------------

yum -y install python-pip
pip install --upgrade pip
pip install virtualenv
yum install python-devel.x86_64 -y
wget -O /root/autoinstall.php $MINE/WebuzoSetup.php
chmod 0755 autoinstall.php
/usr/local/emps/bin/php autoinstall.php $ip $myUser $myPass $myDomain

#----------------------------------
# Change Settings, stop email spam from webuzo, stop autoupdate etc
#----------------------------------
wget -O /usr/local/webuzo/enduser/universal.php $MINE/universal.php


#----------------------------------
# Nginx
#----------------------------------
cd /root
read -p 'Install NGINX (y/n)?: ' mynx
if [ "$mynx" == "y" ]; then 
	yum install pcre-devel zlib-devel openssl-devel -y
	mkdir nginx
	cd nginx
	wget http://nginx.org/download/nginx-1.10.2.tar.gz
	tar -zxvf *.tar.gz
	cd nginx-1.10.2
	./configure --prefix=/usr/local/apps/nginx --sbin-path=/usr/local/apps/nginx/sbin/nginx --conf-path=/usr/local/apps/nginx/etc/nginx.conf --error-log-path=/usr/local/apps/nginx/var/log/error.log --http-log-path=/usr/local/apps/nginx/var/log/web.access.log --with-http_ssl_module
	make
	make install
	wget https://raw.githubusercontent.com/jsEveryDay/CentOS-Config/master/setup/mynginx.tar.gz
	tar -zxvpf mynginx.tar.gz -C /usr/local/apps
	ln -s /usr/local/apps/nginx/sbin/nginx /usr/sbin/nginx
	ln -s /usr/local/apps/nginx/bin/nginxctl /etc/rc.d/init.d/nginx
	sed -i '$ a WU_DEFAULT_SERVER=nginx' /var/webuzo/webuzo.conf
	cd /root
	rm -rf nginx
	echo "Done! Dont forget. run mynginx then nano, to set the domain."
else echo "Skipped"
fi


#----------------------------------
# CSF
#----------------------------------
cd /root
read -p 'InstallCSF (y/n)?: ' mycsf
if [ "$mycsf" == "y" ]; then 
	/etc/init.d/iptables stop
	yum install perl-Crypt-SSLeay perl-Net-SSLeay -y
	cd /usr/src
	rm -fv csf.tgz
	wget https://download.configserver.com/csf.tgz
	tar -xzf csf.tgz
	cd csf
	./install.generic.sh
	wget -O /etc/csf/csf.conf $MINE/csf.conf
	read -p 'Ip to Whitelist: ' localip
	csf -a $localip
	csf -r
	echo "Done!!"
else echo "Skipped"
fi



#----------------------------------
# Change SSH Port
#----------------------------------

cd /root
read -p 'Set SSH Port: ' sshport
if [ -n "$sshport" ]; then 
		sed -i "s/#Port 22/Port $sshport/" /etc/ssh/sshd_config
	echo "Done!!"
else echo "Skipped"
fi

#----------------------------------
# Install Mongodb
#----------------------------------

cd /root
read -p 'Setup Mongo?: ' mong
if [ "$mong" == "y" ]; then 
		cd /etc/yum.repos.d
		wget https://repo.mongodb.org/yum/redhat/mongodb-org.repo
		yum install -y mongodb-org
		sed -i "s/bindIp: 127.0.0.1/bindIp: 127.0.0.1,$ip/" /etc/mongod.conf
	echo "Done!! Added Server IP too"
else echo "Skipped"
fi

#----------------------------------
# CleanUP
#----------------------------------
cd /root
read -p 'Cleanup and Secure (y/n)?: ' cleanme
if [ "$cleanme" == "y" ]; then 
	rm -rf rar
	rm -rf *.tar.gz
	rm -rf install.sh
	rm -rf *.php
	rm -rf *.rpm
	rm -rf *.log
	yum -y install yum-cron
	/etc/init.d/yum-cron start
	chkconfig yum-cron on
	rm -rf /var/webuzo/users/$myUser/*
	chmod 000 /var/webuzo/users/$myUser
	echo "Done!!"
else echo "Skipped"
fi

wget -O /home/$myUser/usersetup.sh $MINE/usersetup.sh
chmod 777 /home/$myUser/usersetup.sh

echo "DONT FORGET"
echo "-------------------------------------"
echo "Delete webuzo http 2002 and 2004"
echo "nano /usr/local/webuzo/conf/webuzo/emps/nginx.conf"
echo "-------------------------------------"
echo "New SSH Port $sshport"
