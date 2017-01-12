#! /bin/bash

# $1 - domain/subdomain
# $2 - app root

# nginx need the fullchain to work properly in all browsers
cp /etc/letsencrypt/live/$1/fullchain.pem $2/conf/certs/$1.crt
cp /etc/letsencrypt/live/$1/privkey.pem $2/conf/certs/$1.key

