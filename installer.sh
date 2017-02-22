#!/bin/bash
temp_dir="/tmp/install"
vhost_dir="/home/vhost"

#update repo
sudo add-apt-repository ppa:ondrej/php -y

#update ubuntu
sudo apt -y update && sudo apt -y upgrade

#install depencies
sudo apt -y install git zip unzip nginx

#update timezone
sudo rm /etc/localtime
sudo su - root -c 'ln -s /usr/share/zoneinfo/Asia/Jakarta /etc/localtime'

#get the files
#git clone https://github.com/dwippoer/ubuntu-nginx-multiple-php.git $temp_dir

#remove any installed php version
sudo which php
if [ $? == 0 ];
then
	sudo apt -y purge php*;
fi

#install php 7.1
sudo apt -y install php7.1-fpm php7.1-cli php7.1-common php7.1-gd php7.1-mysql php7.1-mbstring php7.1-mcrypt php7.1-curl php7.1-odbc php7.1 php7.1-gettext php7.1-json php7.1-xml php7.1-xmlrpc php7.1-xsl

#install php 5.6
sudo apt -y install php5.6-fpm php5.6-cli php5.6-common php5.6-gd php5.6-mysql php5.6-mbstring php5.6-mcrypt php5.6-curl php5.6-odbc php5.6 php5.6-gettext php5.6-json php5.6-xml php5.6-xmlrpc php5.6-xsl

#update nginx
sudo su - root -c 'rm -f /etc/nginx/nginx.conf'
sudo su - root -c 'cp $temp_dir/nginx.conf /etc/nginx'
sudo su - root -c 'cp $temp_dir/vhost1.conf /etc/nginx/conf.d'

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
<<<<<<< HEAD
#update php 5.6
sudo su - root -c 'sed -i "/;cgi.fix_pathinfo=1/c\cgi.fix_pathinfo=0" /etc/php/5.6/fpm/php.ini'
sudo su - root -c 'sed -i "/;date.timezone =/c\date.timezone = Asia/Jakarta" /etc/php/5.6/fpm/php.ini'
sudo su - root -c 'sed -i "/listen = /run/php/php5.6-fpm.sock/c\listen = 127.0.0.1:9000" /etc/php/5.6/fpm/pool.d/www.conf'
sudo systemctl start php5.6-fpm
sudo systemctl enable php5.6-fpm

#update php 7.1
sudo su - root -c 'sed -i "/;cgi.fix_pathinfo=1/c\cgi.fix_pathinfo=0" /etc/php/7.1/fpm/php.ini'
sudo su - root -c 'sed -i "/;date.timezone =/c\date.timezone = Asia/Jakarta /etc/php/7.1/fpm/php.ini'
sudo su - root -c 'sed -i "/listen = /run/php/php7.1-fpm.sock/c\listen = 127.0.0.1:9001" /etc/php/7.1/fpm/pool.d/www.conf'
sudo systemctl start php7.1-fpm
sudo sytemctl enable php7.1-fpm

exit 0
=======
>>>>>>> 3a645c96a57bc79a07cdc13d857afa21dac3d9de
