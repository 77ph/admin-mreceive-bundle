#!/bin/bash

## скрипт выполняемый, на удаленной системе от непривелигированного пользователя с sudo без пароля из его домашнего каталога

# http://stackoverflow.com/questions/17606340/how-to-deploy-a-meteor-application-to-my-own-server

#step 0 (update/upgrade)
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install git

#step 1 - mongodb-c driver (preprocess for mreceive.bin)
sudo apt-get -y install build-essential gcc dpkg-dev cdbs automake autoconf libtool make libssl-dev libsasl2-dev git python-lxml pkg-config

#step 3 - mongodb
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
sudo apt-get update
sudo apt-get install -y mongodb-org

#step 4 - preprocess for network utils
sudo apt-get -y install ipcalc
git clone https://github.com/dggreenbaum/debinterface
sudo cp -r ./debinterface /usr/local/lib/python2.7/dist-packages
rm -rf ./debinterface

#step 5 - preprocess for timezone utils
sudo apt-get install -y systemd-services

#step 6 install nginx
sudo apt-get install -y nginx

#step 7 - install sendemail (MTA)
apt-get install -y sendemail

#step 8 - install ethereum (geth)
sudo apt-get install software-properties-common
sudo add-apt-repository -y ppa:ethereum/ethereum
sudo apt-get update
sudo apt-get install -y ethereum

if [ ! -f /etc/init/ethereum.conf ]; then
	sudo cat << EOF > /etc/init/ethereum.conf
description "geth (Ethereum (ETH)) application"
author "Andrey Leb <admin@vqm.io>"

# When to start the service
start on started networking and runlevel [2345]

# When to stop the service
stop on shutdown

# Automatically restart process if crashed
respawn
respawn limit 10 5

# we don't use buil-in log because we use a script below
# console log

# drop root proviliges and switch to mymetorapp user
setuid admin_mreceive
setgid admin_mreceive


post-start script
	sudo cpulimit -e geth -l 30 &
end script


script
	exec geth --syncmode fast --testnet --rpc --rpcaddr=localhost
end script

EOF
fi

#step 9 install tstool
sudo apt-get install -y tstools

#step 10 finish
sudo dpkg -i mongo-c-driver_1.3.0-3_amd64.deb
sudo dpkg -i mreceive-vbr-network-utils_0.0.1-1.1_amd64.deb
sudo dpkg -i mreceive-vbr-timezone-utils_0.0.1-2_amd64.deb
sudo dpkg -i mreceive-vbr_0.4.13_amd64.deb
sudo dpkg --force-all -i admin-mreceive_0.5-6_amd64.deb
stop admin_mreceive
start admin_mreceive
