#!/bin/bash

echo "Creating nginx-cron"
cp sample.nginx-cron nginx-cron
cp sample.renew-certs.sh renew-certs.sh

sed -i "s#{path-nginx}#$(pwd)#g" nginx-cron
sed -i "s#{path-nginx}#$(pwd)#g" renew-certs.sh

echo "Move nginx-cron to /etc/cron.d"
mv nginx-cron /etc/cron.d

