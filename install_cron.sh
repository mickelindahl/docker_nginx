#!/bin/bash
cp sample.nginx-cron nginx-cron
cp sample.renew.sh renew.sh

sed -i "s#{path-nginx}#$(pwd)#g" nginx-cron
sed -i "s#{path-nginx}#$(pwd)#g" renew.sh

mv nginx-cron /etc/cron.d

