## Grassy docker nginx

Reverse proxy with nginx server in docker container from (https://github.com/jwilder/nginx-proxy).

Copy sample.docker-compose.yml to docker-compose.yml.Change paths to volumes in docker-compose 
accordingly to your environemnt. Run `docker-compose up` -d in app directory to start service.

### SSL certificate from letsencrypt

In `/etc/apt/sources.list` add `deb http://ftp.debian.org/debian jessie-backports main`

Run `sudo apt-get update` then `sudo apt-get install certbot -t jessie-backports`

Stop nginx server if active

Run `certbot certonly --standalone -d {domaim/subdomain}` or just `certbot certonly` and follow instructions.

It will state were certs ends upp. Copy cert to certs directory using `copy_cert.sh` script   
For example, a container with VIRTUAL_HOST=foo.bar.com should have a 
foo.bar.com.crt and foo.bar.com.key file in the certs directory (see https://github.com/jwilder/nginx-proxy)

### SSL certificate renewal

Setup cron job for certificate renewal. First renew certs with certbpt renew and then copy them with 
`copy_cert.sh`). 

Run crontab -e and add `0 0 1 * * certbot renew` to run crontab renew one time each week

Then add one line for each domain/subdomain `0 10 1 * * {path to app}/copy_cert.sh the.domain.se {path to app}`
to copy cert 10 minutes after renewal. To recieve emails once job has run add MAILTO="your@email.se". OBS also 
need to configure email server on the server.

### Server email support
Configure mailgun with postfix such that server can send emails.

Run `apt-get update` and `apt-get install postfix libsasl2-modules`

Then in /etc/postfix/main.cf add

"""
relayhost = smpt.mailgun.org:587
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps=static:postmaster@yourdomain.se:{long id}
"""

Reload postfix `service postfix restart`
