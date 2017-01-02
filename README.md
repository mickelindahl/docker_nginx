# Grassy docker nginx

Reverse proxy with nginx server in docker container from [jwilder/nginx](https://github.com/jwilder/nginx-proxy).

Copy `sample.docker-compose.yml` to `docker-compose.yml`. Change paths to volumes in `docker-compose.yml` 
accordingly to your environemnt. Run `docker-compose up` -d in app directory to start service.

Remarks
- If only 1 port exposed, then that port is used. No need for setting environment varialbe `VIRTUAL_PORT`.
- With docker-compose.yml `version: "2"` one need to set network_mode: "bridge" for ut to work out of the box. 
Otherwise one need to add the compose network  to nginx see [https://docs.docker.com/compose/networking/](compose networking) 
and [jwilder/nginx](https://github.com/jwilder/nginx-proxy).

## Installation

Clone repository and cd into app directory

Run `mkdir conf && cp added.conf ./conf` in apps root.  

Run `cp sample.docker-compose.yml docker-compose.yml`

To build and  `docker-compose up -d

## SSL certificate from letsencrypt

Add to `docker-compose.yml`:
``` 
volumes:
   - /var/run/docker.sock:/tmp/docker.sock
   - ./conf:/etc/nginx/conf.d
   - ./certs:/etc/nginx/certs` # Added
ports:
   - "80:80"
   - "443:443" Added
```

Run `mkdir certs` in apps root

Add new backport to source.list 
```
echo /etc/apt/sources.list < deb http://ftp.debian.org/debian jessie-backports main
```

Run 
```
sudo apt-get update && sudo apt-get install certbot -t jessie-backports
```

Stop nginx server if active

Run `sudo certbot certonly --standalone -d {domaim/subdomain}` or just `sudo certbot certonly` and follow instructions.

It will state were certs ends up (/etc/letsencrypt/archive/). Copy cert to certs directory using `copy_cert.sh` script   
For example, a container with VIRTUAL_HOST=foo.bar.com should have a 
foo.bar.com.crt and foo.bar.com.key file in the certs directory (see https://github.com/jwilder/nginx-proxy)

## SSL certificate renewal

Setup cron job for certificate renewal. First renew certs with certbot renew and then copy them with 
`copy_cert.sh`). 

Run crontab -e and add `0 0 1 * * certbot renew` to run crontab renew one time each week

Then add one line for each domain/subdomain `0 10 1 * * {path to app}/copy_cert.sh the.domain.se {path to app}`
to copy cert 10 minutes after renewal. To recieve emails once job has run add MAILTO="your@email.se". OBS also 
need to configure email server on the server.

## Server email support
Configure mailgun with postfix such that server can send emails.

Run `apt-get update` and `apt-get install postfix libsasl2-modules`

Then in /etc/postfix/main.cf add

```
relayhost = smpt.mailgun.org:587
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps=static:postmaster@yourdomain.se:{password}
```

Reload postfix `service postfix restart`
