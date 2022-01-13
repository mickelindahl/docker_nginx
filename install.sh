#!/bin/bash

NETWORK=nginx

if [ ! $USER==root ]; then
    echo "Please run as root"
    exit
fi

DEFAULT_DOMAIN = $1

cp sample.monitor-cron monitor-cron

sed -i "s#{src}#$(pwd)#g" monitor-cron
mv monitor-cron /etc/cron.d/nginx-monitor-cron

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
#cp nginx-error.conf ./conf/vhost.d/whiteboard.greencargo.com
#cp nginx-error.conf ./conf/conf.d/nginx-error.conf

# Error pages
if [ ! -d html ]; then
  mkdir -p html
  cp 50x.html html/503.html
  cp index.html html/index.html
fi

if [ -f redirects.conf ]; then

  echo "Copy redirect.conf"
  cp redirects.conf ./conf/conf.d/redirects.conf

fi

echo "Create compose file"
cp sample.docker-compose.yml docker-compose.yml

if [ -f virtual-hosts-local ]; then

  # Greencargo specific config
  if [ -f  local-certs/greencargo.com.crt ]; then
     VIRTUAL_HOSTS_LOCAL=`cat virtual-hosts-local | tr '\n' ' '`
     for host in $VIRTUAL_HOSTS_LOCAL; do

        echo "Adding cert and key for local  $host"
        cp ./local-certs/greencargo.com.crt conf/certs/$host.crt
        cp ./local-certs/greencargo.com.key conf/certs/$host.key

     done

     # Create default certs used for 503 page
     cp ./local-certs/greencargo.com.crt conf/certs/default.crt
     cp ./local-certs/greencargo.com.key conf/certs/default.key

   fi
elif [ -f virtual-hosts ]; then

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

  if [ -z DEFAULT_DOMAIN ]; then

      echo "Create default certs used for 503 page"
      cp ./local-certs/greencargo.com.crt conf/certs/default.crt
      cp ./local-certs/greencargo.com.key conf/certs/default.key

   fi
else

  echo "Missing files in  virtual-hosts or virtual-hosts-local files"
  echo "This means that the server will not have ssh certificates"
  read -p "Continue (Y/n)?" choice
  case "$choice" in
       n|N ) exit ;;
       * ) echo "Continue" ;;
  esac

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

   echo "Missing piwik configuration. Removing option from docker-compose"
   sed -i "s#{piwik-path-html}##g" docker-compose.yml

fi

# Missing from sample.docker-compose.yml
#sed -i "s#{http-proxy}#$http_proxy#g" docker-compose.yml
#sed -i "s#{https-proxy}#$https_proxy#g" docker-compose.yml

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
