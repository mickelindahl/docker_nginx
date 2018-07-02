#!/bin/bash

NETWORK=nginx

if [ ! $USER==root ]; then
    echo "Please run as root"
fi

cp sample.monitor.cron monitor.cron

sed -i "s#{src}#$(pwd)#g" monitor.cron
mv monitor.cron /etc/cron.d/nginx-monitor.cron

echo "Remove old conf"
rm -r conf/conf.d
rm -r conf/certs

echo "Create directories"

if [ ! -d conf/vhost ]; then
  mkdir -p conf/vhost.d
fi
mkdir -p conf/conf.d
mkdir -p conf/certs

echo "Copy added.conf"
cp added.conf ./conf/conf.d/added.conf

echo "Create compose file"
cp sample.docker-compose.yml docker-compose.yml

if [ -f virtual-hosts-local ]; then

  VIRTUAL_HOSTS_LOCAL=`cat virtual-hosts-local | tr '\n' ' '`
  for host in $VIRTUAL_HOSTS_LOCAL; do

     echo "Adding cert and key for local  $host"
     cp ./local-certs/greencargo.com.crt conf/certs/$host.crt
     cp ./local-certs/greencargo.com.key conf/certs/$host.key

  done

fi

if [ -f nginx-piwik.env ]; then

   export $(cat nginx-piwik.env | xargs)

   for arg in "PIWIK_PATH_HTML"; do

        if [ "${!arg}" = "" ];then
            echo "Missing env $arg in piwik.env"
            exit 1
        fi

   done

   sed -i "s#{piwik-path-html}#- $PIWIK_PATH_HTML:/var/www/html#g" docker-compose.yml

else

   sed -i "s#{piwik-path-html}##g" docker-compose.yml


fi

sed -i "s#{http-proxy}#$http_proxy#g" docker-compose.yml
sed -i "s#{https-proxy}#$https_proxy#g" docker-compose.yml


if [ -f virtual-hosts ]; then

  echo "Create virtual host certificates"

  VIRTUAL_HOSTS=`cat virtual-hosts | tr '\n' ' '`
  for host in $VIRTUAL_HOSTS; do

     ./add_certificate.sh $host

  done

  echo "Create copy all certs script"
  cp sample.copy_all_certs.sh copy_all_certs.sh

  sed -i "s#{path-nginx}#$(pwd)#g" copy_all_certs.sh

  ./copy_all_certs.sh

  ./install_cron.sh

else

  read -p "Missing virtual-hosts file continue (Y/n)?" choice
  case "$choice" in
       n|N ) exit ;;
       * ) echo "Continue" ;;
  esac

fi



TMP=`docker network ls | grep $NETWORK`
if [ -z "$TMP" ]; then
   echo "Create external network"
   docker network create -d bridge $NETWORK
fi

echo "Stop and remove old instances" 
docker-compose stop
docker-compose rm -f

echo "Start"
docker-compose --compatibility up -d
