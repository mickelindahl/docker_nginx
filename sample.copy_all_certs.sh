#!/bin/bash

echo "Set HOME=/opt/apps/nginx"
export HOME=/opt/apps/docker_nginx

echo "Declare array"
declare -a arr=("{domain/subdomain}" \
		"{subdomain}" \
		"... etc")

echo "Loop through the above array"
for i in "${arr[@]}"
do

  echo "Copying cert and key for $i"
  $HOME/copy_cert.sh $i $HOME

   # or do whatever with individual element of the array
done
