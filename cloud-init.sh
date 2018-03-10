#!/bin/bash

cd /root
USER="radio" # Change this to the user you want created

cd /root/
echo "`date` Start install" >> /root/install.log

curl https://raw.githubusercontent.com/ScanOC/cloud-init/master/install.sh -o install.sh >> /root/install.log 2>&1
chmod +x install.sh >> /root/install.log 2>&1
./install.sh $USER >> /root/install.log 2>&1
