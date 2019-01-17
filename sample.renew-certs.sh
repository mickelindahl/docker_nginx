#!/bin/bash

echo `date`

docker stop nginx 
certbot renew 
{path-nginx}/copy_all_certs.sh
docker start nginx
