#!/bin/bash

echo "Set HOME_NGINX={path-nginx}"
export HOME_NGINX={path-nginx}

echo "Declare array"
#declare -a arr=("{domain/subdomain}" \
#		"{subdomain}" \
#		"... etc")

if [ ! -f $HOME_NGINX/virtual-hosts ]; then
  echo "Missing virtual-host file. Please create it. See README.md"
  exit
fi 

VIRTUAL_HOSTS=`cat virtual-hosts | tr '\n' ' '`

echo "Loop through the above array"
for host in $VIRTUAL_HOSTS
do

  echo "Copying cert and key for $host"
  $HOME_NGINX/copy_cert.sh $host $HOME_NGINX

   # or do whatever with individual element of the array
done
