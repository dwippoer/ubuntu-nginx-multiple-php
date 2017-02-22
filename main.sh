#!/bin/bash
temp_dir="/tmp/install"


#get the files
if [ -d $temp_dir ];
then
        sudo rm -rf $temp_dir;
fi
git clone https://github.com/dwippoer/ubuntu-nginx-multiple-php.git $temp_dir

#install
/bin/bash $temp_dir/installer.sh
