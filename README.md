### Configuration

Copy sample.docker-compose.yml to docker-compose.yml.Change paths to volumes in docker-compose 
accordingly to your environemnt. Run `docker-compose up` -d in app directory to start service.

## SSL certificates

In /etc/apt/sources.list add deb http://ftp.debian.org/debian jessie-backports main

Run sudo apt-get update then sudo apt-get install certbot -t jessie-backports

Stop webserver if active

certbot certonly --standalone -d {domaim/subdomain}

It will state were certs ends upp. Copy cert to certs directory using `copy_cert.sh` script   
For example, a container with VIRTUAL_HOST=foo.bar.com should have a 
foo.bar.com.crt and foo.bar.com.key file in the certs directory (see https://github.com/jwilder/nginx-proxy)

## Cron 

Setup cron job for renewal of cron jobs. First renew certs with certbpt renew and then copy them with 
`copy_cert.sh`). 
