# Docker nginx

Reverse proxy with nginx server in docker container from [jwilder/nginx](https://github.com/jwilder/nginx-proxy).

Copy `sample.docker-compose.yml` to `docker-compose.yml`. Change paths to volumes in `docker-compose.yml` 
accordingly to your environemnt. Run `docker-compose up` -d in app directory to start service.

Remarks
- If only 1 port exposed, then that port is used. No need for setting environment varialbe `VIRTUAL_PORT`.
- With docker-compose.yml `version: "2"` one need to set network_mode: "bridge" for ut to work out of the box. 
Otherwise one need to add the compose network  to nginx see [https://docs.docker.com/compose/networking/](compose networking) 
and [jwilder/nginx](https://github.com/jwilder/nginx-proxy).
- If you get "502 Bad Gatway" after rebuilding an app one might need to delete the conf directory and 
recreate nginx container

## Installation

Clone repository and cd into app directory

Run `mkdir -p conf/vhost.d && mkdir -p conf/conf.d && mkdir conf/certs && cp added.conf ./conf/conf.d` in apps root.  

Run `cp sample.docker-compose.yml docker-compose.yml`

To build and  `docker-compose up -d

## SSL certificate from letsencrypt

Add to `docker-compose.yml`:
``` 
Change to user with sudo

Add new backport to source.list 
```
sudo sh -c "echo 'deb http://ftp.debian.org/debian jessie-backports main' >> /etc/apt/sources.list"
```

Then run `sudo apt-get update && sudo apt-get install certbot -t jessie-backports`

Stop nginx server if active

Run `sudo certbot certonly --standalone -d {domaim/subdomain}` or just `sudo certbot certonly` and follow instructions.

Change owner of /etc/letsencrypt/archive to user that will run apps `sudo chown -R {group}:{user} /etc/letsencrypt/archive`

Change back to app user

Run `cp sample.copy_all_certs.sh copy_all_certs.sh` and add your app dir and subdomains to `copy_all_certs.sh`

Copy certs `./copy_all_certs.sh`

Done!
 
## SSL certificate renewal

Setup cron job for certificate renewal. First renew certs with certbot renew and then copy them with 
`copy_cert.sh`). 

Run crontab -e and add 
```
0 0 1 * * certbot renew
0 10 1 * * {path to app}/copy_all_certs.sh the.domain.se {path to app}
```
To recieve emails once job has run add MAILTO="your@email.se". OBS also 
need to configure email server on the server.

### SSL certificate removal
This is being worked on for furtre realese (see)[https://community.letsencrypt.org/t/remove-domain-not-required-from-cert/14010].
Here is a workaround that should work.

```
rm -rf /etc/letsencrypt/live/${DOMAIN}
rm -rf /etc/letsencrypt/archive/${DOMAIN}
rm /etc/letsencrypt/renewal/${DOMAIN}.conf
```
## Server email support
Configure mailgun with postfix such that server can send emails.

Run `sudo apt-get update && sudo apt-get install postfix libsasl2-modules`

Run `sudo nano /etc/postfix/main.cf` and add

```
relayhost = smpt.mailgun.org:587
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps=static:postmaster@yourdomain.se:{password}
```

Reload postfix `sudo service postfix restart`

Test with `mail -s "Test mail" mikael.lindahlgreencargo.se <<< "A test message using Mailgun"
`

## Piwik
For setup with piwik se [link](https://github.com/mickelindahl/docker_piwik)
