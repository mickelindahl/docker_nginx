#!/bin/bash

echo "Stop monitoring"
./monitor.sh disable -m "Renew letsencrypt https certificates start"

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

echo "Start monitoring again"
./monitor.sh enable -m "Renew letsencrypt https certificates done"


