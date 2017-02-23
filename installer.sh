#!/bin/bash
temp_dir="/tmp/install"
vhost_dir="/home/vhost"
services="nginx mysql"
phpmyadmin_dir="/usr/share/phpmyadmin"

#update repo
sudo add-apt-repository ppa:ondrej/php -y

#update ubuntu
sudo apt -y update && sudo apt -y upgrade

#install depencies
sudo apt -y install git zip unzip nginx

#update timezone
sudo rm /etc/localtime
sudo su - root -c 'ln -s /usr/share/zoneinfo/Asia/Jakarta /etc/localtime'

#remove apache2
sudo which apache2
if [ $? == 0 ];
then
	sudo apt -y purge apache2;
fi

#remove any installed php version
sudo which php
if [ $? == 0 ];
then
	sudo apt -y purge php*;
fi

#install php 7.0
sudo apt -y install php7.0-fpm php7.0-cli php7.0-common php7.0-gd php7.0-mysql php7.0-mbstring php7.0-mcrypt php7.0-curl php7.0-odbc php7.0 php7.0-gettext php7.0-json php7.0-xml php7.0-xmlrpc php7.0-xsl

#install php 7.1
sudo apt -y install php7.1-fpm php7.1-cli php7.1-common php7.1-gd php7.1-mysql php7.1-mbstring php7.1-mcrypt php7.1-curl php7.1-odbc php7.1 php7.1-gettext php7.1-json php7.1-xml php7.1-xmlrpc php7.1-xsl

#install php 5.6
sudo apt -y install php5.6-fpm php5.6-cli php5.6-common php5.6-gd php5.6-mysql php5.6-mbstring php5.6-mcrypt php5.6-curl php5.6-odbc php5.6 php5.6-gettext php5.6-json php5.6-xml php5.6-xmlrpc php5.6-xsl

#update nginx
sudo su - root -c 'chown -R root:root /var/log/nginx && chmod 775 /var/log/nginx'
sudo su - root -c 'rm -f /etc/nginx/nginx.conf'
sudo su - root -c 'cp /tmp/install/nginx.conf /etc/nginx'
sudo su - root -c 'cp /tmp/install/vhost.conf /etc/nginx/conf.d'
sudo su - root -c 'cp /tmp/install/phpmyadmin-vhost.conf /etc/nginx/conf.d'

#create vhost dir
if [ ! -d $vhost_dir ];
then
	sudo mkdir $vhost_dir;
fi

sudo chmod 775 $vhost_dir
sudo chown -R www-data:www-data $vhost_dir

#install mysql server
install_mysql()
{
	sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password DBadmin#!1234'
	sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password DBadmin#!1234'
	sudo apt -y install mysql-server
}	

sudo which mysql
if [ $? == 0 ];
then
	echo "mysql has been installed";
else
	install_mysql;
fi
#update php 5.6
sudo su - root -c 'sed -i "/;cgi.fix_pathinfo=1/c\cgi.fix_pathinfo=0" /etc/php/5.6/fpm/php.ini'
sudo su - root -c 'sed -i "/;date.timezone =/c\date.timezone = Asia/Jakarta" /etc/php/5.6/fpm/php.ini'
sudo su - root -c 'sed -i "/listen = /run/php/php5.6-fpm.sock/c\listen = 127.0.0.1:9000" /etc/php/5.6/fpm/pool.d/www.conf'
sudo systemctl start php5.6-fpm
sudo systemctl enable php5.6-fpm

#update php 7.0
sudo su - root -c 'sed -i "/;cgi.fix_pathinfo=1/c\cgi.fix_pathinfo=0" /etc/php/7.0/fpm/php.ini'
sudo su - root -c 'sed -i "/;date.timezone =/c\date.timezone = Asia/Jakarta" /etc/php/7.0/fpm/php.ini'
sudo su - root -c 'sed -i "/listen = /run/php/php7.0-fpm.sock/c\listen = 127.0.0.1:9001" /etc/php/7.0/fpm/pool.d/www.conf'
sudo systemctl start php7.0-fpm
sudo systemctl enable php7.0-fpm


#update php 7.1
sudo su - root -c 'sed -i "/;cgi.fix_pathinfo=1/c\cgi.fix_pathinfo=0" /etc/php/7.1/fpm/php.ini'
sudo su - root -c 'sed -i "/;date.timezone =/c\date.timezone = Asia/Jakarta" /etc/php/7.1/fpm/php.ini'
sudo su - root -c 'sed -i "/listen = /run/php/php7.1-fpm.sock/c\listen = 127.0.0.1:9002" /etc/php/7.1/fpm/pool.d/www.conf'
sudo systemctl start php7.1-fpm
sudo systemctl enable php7.1-fpm

#phpmyadmin
if [ -d $phpmyadmin_dir ];
then
	sudo mv $phpmyadmin /usr/share/old_phpmyadmin;
fi
wget https://files.phpmyadmin.net/phpMyAdmin/4.6.6/phpMyAdmin-4.6.6-all-languages.zip -P $temp_dir
sudo su - root -c 'unzip $temp_dir/phpMyAdmin*.zip -d /usr/share && mv /usr/share/phpMyAdmin* /usr/share/phpmyadmin'
sudo su - root -c 'cp $phpmyadmin_dir/config.inc.sample.php $phpmyadmin_dir/config.inc.php'
sudo su - root -c 'echo "127.0.0.1	sql.local" >> /etc/hosts'

#change php session ownership
sudo chmod 775 /var/lib/php/session
sudo chown -R www-data:www-data /var/lib/php/session

#restart services
for p in $services
do ps -ef | grep -v grep | grep $p > /dev/null
if [ $? -eq 0 ];
then 
	sudo systemctl start $p;
elif [ $? -gt 0 ];
then
	sudo systemctl restart $p;
fi
done

sudo systemctl restart php5.6-fpm
sudo systemctl restart php7.0-fpm
sudo systemctl restart php7.1-fpm

exit 0
