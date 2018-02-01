#!/bin/bash

if [ ! "$1" = "" ]; then
  
    VIRTUAL_HOST=$1

else  

    read -p "Enter domain/subdomain: " VIRTUAL_HOST

fi

if [ -f /etc/letsencrypt/live/$VIRTUAL_HOST ]; then

   echo "add_certificate $VIRTUAL_HOST already exists, skipping."

fi

docker stop nginx
sudo certbot certonly --standalone -d $VIRTUAL_HOST
docker start nginx
