#!/bin/bash
# Base install script for Trunk-Player
# https://github.com/ScanOC/trunk-player
# Dylan Reinhold 
#----------------------------------------

user=$1
if [ -z $user ]
then
    user="radio"
fi


echo "`date` Started" > /root/INSTALL_STARTED

cd /root/

export DEBIAN_FRONTEND=noninteractive;
apt-get -y update
apt-get -y upgrade

apt-get -y install python3-dev virtualenv redis-server python3-pip postgresql libpq-dev postgresql-client postgresql-client-common git nginx bc supervisor

#!/bin/bash

USER="radio" # Change this to the user you want created

cd /root/
echo "`date` Start install" >> /root/install.log

# Add digital ocean monitoring
curl -sSL https://agent.digitalocean.com/install.sh | sh

adduser $user --gecos "" --disabled-password

db_pass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9-_!@#+' | fold -w 12 | head -n 1)
django_secret_key=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9-_!@#+' | fold -w 64 | head -n 1)

curl https://raw.githubusercontent.com/ScanOC/cloud-init/master/postgres_setup.sql -o postgres_setup.sql
sed "s/__DB_PASS__/$db_pass/g" < postgres_setup.sql > ~postgres/postgres_setup.sql
chown postgres ~postgres/postgres_setup.sql
su - postgres -c "psql < ~postgres/postgres_setup.sql"
rm -f ~postgres/postgres_setup.sql

curl https://raw.githubusercontent.com/ScanOC/cloud-init/master/tp-settings.tmpl -o tp-settings.tmpl 

sed -e "s/__DB_PASS__/$db_pass/g" \
    -e "s/__SECRET_KEY__/$django_secret_key/g" < tp-settings.tmpl > /home/$user/tp-settings.tmpl
chown $user /home/$user/tp-settings.tmpl

curl https://raw.githubusercontent.com/ScanOC/cloud-init/master/tp-setup.sh -o tp-setup.sh
cp tp-setup.sh /home/$user/tp-setup.sh
chown $user /home/$user/tp-setup.sh
chmod 744 /home/$user/tp-setup.sh

su - $user -c "cd /home/$user && ./tp-setup.sh"

rm -f /etc/nginx/sites-enabled/default
ln -s /home/$user/trunk-player/trunk_player/nginx.conf /etc/nginx/sites-enabled/001-trunkplayer.conf

ln /home/$user/trunk-player/trunk_player/supervisor.conf /etc/supervisor/conf.d/trunk_player.conf

supervisorctl reread
supervisorctl update

kill -HUP `cat /var/run/nginx.pid`

# Copy ssh keys from root install to new user
if [ -f /root/.ssh/authorized_keys ]
then
    mkdir /home/$user/.ssh
    chown $user:$user /home/$user/.ssh
    chmod 700 /home/$user/.ssh
    cp /root/.ssh/authorized_keys /home/$user/.ssh/authorized_keys
    chown $user:$user /home/$user/.ssh/authorized_keys
    chmod 600 /home/$user/.ssh/authorized_keys
fi

echo "Complete" 
echo "`date` Complete" >> /root/INSTALL_STARTED
mv /root/INSTALL_STARTED /root/INSTALL_COMPLETE
