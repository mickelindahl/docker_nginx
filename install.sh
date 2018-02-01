#!/bin/bash

echo "Create directories"
mkdir -p conf/vhost.d
mkdir -p conf/conf.d
mkdir -p conf/certs

echo "Copy added.conf"
cp added.conf ./conf/conf.d.

echo "Create compose file"
cp sample.docker-compose.yml docker-compose.yml

if [ -f hosts ]; then 

  echo "Create virtual host certificates

  VIRTUAL_HOSTS=cat virtual-hosts | tr '\n' ' '
  for host in $VIRTUAL_HOSTS; do

      ./add_certificate.sh $host

  done

  echo "Create copy all certs script" 
  cp sample.copy_all_certs.sh copy_all_certs.sh

  sed -i "s/{nginx-path}/$(pwd)/g" copy_all_certs.sh

  sudo ./copy_all_certs.sh 

  sudo install_cron.sh

else

  read -p "Missing virtual-hosts file continue? (Y/n)?" choice
  case "$choice" in
       n|N ) exit;;
       * ) echo "Continue";; 
  esac

fi

docker-compose up -d
