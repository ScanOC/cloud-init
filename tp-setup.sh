#!/bin/bash

cd ~

git clone https://github.com/ScanOC/trunk-player.git
cd trunk-player
virtualenv -p python3 env --prompt='(Trunk Player)'
source env/bin/activate

pip install -r requirements.txt

cp ~/tp-settings.tmpl trunk_player/settings_local.py

./manage.py migrate

mkdir static

./manage.py collectstatic --noinput

my_path=$(pwd)

curl https://raw.githubusercontent.com/ScanOC/cloud-init/master/nginx.tmpl -o nginx.tmpl

sed "s#__PATH__#$my_path#g" < nginx.tmpl > trunk_player/nginx.conf
rm -f nginx.tmpl

curl https://raw.githubusercontent.com/ScanOC/cloud-init/master/supervisor.conf.tmpl -o supervisor.conf.tmpl
sed "s#__PATH__#$my_path#g" < supervisor.conf.tmpl > trunk_player/supervisor.conf

