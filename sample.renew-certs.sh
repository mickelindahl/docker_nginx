#!/bin/bash

echo `date`
echo "Stopping nginx"
docker stop nginx

echo "Wait 5 sec"
sleep 5

echo "Renew certs" 
certbot renew 

cd {path-nginx}
./copy_all_certs.sh

echo `date`
echo "Starting nginx"
docker start nginx
