#!/bin/bash

if [ ! $USER==root ]; then
    echo "Please run as root"
fi

if [ ! "$1" = "" ]; then

    VIRTUAL_HOST=$1

else

    read -p "Enter domain/subdomain: " VIRTUAL_HOST

fi

echo $VIRTUAL_HOST

if [ -d /etc/letsencrypt/live/$VIRTUAL_HOST ]; then

   echo "add_certificate $VIRTUAL_HOST already exists, skipping."
   exit

fi

echo "S"

docker stop nginx

echo "Wait 10 sec"
sleep 10
certbot certonly --standalone -d $VIRTUAL_HOST
docker start nginx
