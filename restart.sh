#!/bin/bash

echo "Create directories"
mkdir -p conf/vhost.d
mkdir -p conf/conf.d
mkdir -p conf/certs

echo "Copy added.conf"
sudo cp added.conf ./conf/conf.d.

docker-compose stop

if [ -f virtual-hosts ]; then

  echo "Create virtual host certificates"

  VIRTUAL_HOSTS=sudo cat ./virtual-hosts | tr '\n' ' '
  for host in $VIRTUAL_HOSTS; do

      ./add_certificate.sh $host

  done

  echo "Create copy all certs script"
  sudo cp sample.renew-certs.sh renew-certs.sh

  sudo sed -i "s#{path-nginx}#$(pwd)#g" renew-certs.sh

  sudo ./renew-certs.sh

else

  read -p "Missing virtual-hosts file continue? (Y/n)?" choice
  case "$choice" in
       n|N ) exit ;;
       * ) echo "Continue" ;;
  esac

fi

docker-compose start
