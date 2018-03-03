#!/bin/bash

if [ ! $USER==root ]; then
    echo "Please run as root"
fi


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

if [ -d local-certs ]; then

   cp local-certs/* conf/certs

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

echo ""Stop and remove old instances 
docker-compose stop
docker-compose rm -f

echo "Start"
docker-compose up -d
