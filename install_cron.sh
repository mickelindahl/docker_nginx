#!/bin/bash
cp sample.nginx-cron nginx-cron

cp sample.renew-certs.sh renew-certs.sh

sed -i "s#{path-nginx}#$(pwd)#g" nginx-cron
sed -i "s#{path-nginx}#$(pwd)#g" renew-certs.sh

mv nginx-cron /etc/cron.d

