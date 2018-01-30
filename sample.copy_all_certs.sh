#!/bin/bash

echo "Set HOME={path-nginx}"
export HOME={path-nginx}/docker_nginx

echo "Declare array"
#declare -a arr=("{domain/subdomain}" \
#		"{subdomain}" \
#		"... etc")

if [ ! -f virtual-hosts ]; then
  echo "Missing virtual-host file. Please create it. See README.md"
  exit
fi 

VIRTUAL_HOSTS=cat virtual-hosts | tr '\n' ' '

echo "Loop through the above array"
for host in $VIRTUAL_HOSTS
do

  echo "Copying cert and key for $host"
  $HOME/copy_cert.sh $host $HOME

   # or do whatever with individual element of the array
done
