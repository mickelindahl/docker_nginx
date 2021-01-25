#!/bin/bash

# Example run as root
# ./generate_key_and_crt_from_pem.sh

cd "local-certs"
openssl rsa -in greencargo.com.pem -out greencargo.com.key
openssl crl2pkcs7 -nocrl -certfile greencargo.com.pem | openssl pkcs7 -print_certs -out greencargo.com.crt
