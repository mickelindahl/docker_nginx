#! /bin/bash

# $1 - domain/subdomain
# $2 - app root

cp /etc/letsencrypt/archive/$1/cert1.pem $2/certs/$1.crt
cp /etc/letsencrypt/archive/$1/privkey1.pem $2/certs/$1.key

