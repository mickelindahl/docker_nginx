#!/bin/bash

cd {path-nginx}

echo "Stop monitoring"
echo "Eenew letsencrypt https certificates" > "monitor.stop"

echo "Wait 5 sec"
sleep 5

echo `date`
echo "Stopping nginx"
docker stop nginx

echo "Wait 5 sec"
sleep 5

echo "Renew certs" 
certbot renew 

./copy_all_certs.sh

echo `date`
echo "Starting nginx"
docker start nginx


echo "Wait 5 sec"
sleep 5

echo "Start monitoring agaon"
rm "monitor.stop"

