# Docker nginx

Reverse proxy with nginx server in docker container from [jwilder/nginx](https://github.com/jwilder/nginx-proxy).

## Installation

Make sure certbot is installed [more info](https://letsencrypt.org/getting-started/)

Clone repository and cd into app directory

Copy `cp sample.virtual-hosts virtual-hosts` and add virtual hosts. One for each row.

Run `install.sh` in apps root.  

Ensure your apps `docker-compose.yml` files that nginx are rerouting to contains 
```
networks:
  nginx:
     external: true

```

And specific service/s that nginx should reach includes 
```
     networks:
        - nginx
```


## SSL certificate from letsencrypt

## Install cerbot debian
Change to user with sudo

Add new backport to source.list 
```
sudo sh -c "echo 'deb http://ftp.debian.org/debian jessie-backports main' >> /etc/apt/sources.list"
```
Then run `sudo apt-get update && sudo apt-get install certbot -t jessie-backports`

## Add certificate

//Stop nginx server if active

Run `add_certificate`
//Run `sudo certbot certonly --standalone -d {domaim/subdomain}` or just `sudo certbot certonly` and follow instructions.

//Change owner of /etc/letsencrypt/archive to user that will run apps `sudo chown -R {group}:{user} /etc/letsencrypt/archive`

//Change back to app user

## Enable certificates

Run `cp sample.copy_all_certs.sh copy_all_certs.sh` and add your app dir and subdomains to `copy_all_certs.sh`

Copy certs `sudo ./copy_all_certs.sh`

Done!
 
## SSL certificate renewal

Setup cron job for certificate renewal (ass root). First renew certs with certbot renew and then copy them with 
`copy_all_certs.sh`). 

Run `sudo install_cron.sh`

// Run crontab -e and add 
// ```
// 0 0 1 * * docker stop  {nginx container} && certbot renew && {path to nginx}/copy_all_certs.sh && docker start {nginx container}
// ```

## Cron email
To recieve emails once job has run `crontab -e` add MAILTO="your@email.se". OBS also 
need to configure email server on the server.

DEbug crontab by following Open terminal and run tail -f /var/log/syslog

## Allow specific ip adressed on subdomain

Copy `sample.block.conf` to conf/vhost.d and make sure you name the file
as the subdomain

`cp sample.block.conf conf/vhost.d/{your.subdomian.com}`

Add allowed ips in `conf/vhost.d/{your.subdomian.com}` 

### SSL certificate removal
This is being worked on for furtre realese (see)[https://community.letsencrypt.org/t/remove-domain-not-required-from-cert/14010].
Here is a workaround that should work.

```
rm -rf /etc/letsencrypt/live/${DOMAIN}
rm -rf /etc/letsencrypt/archive/${DOMAIN}
rm /etc/letsencrypt/renewal/${DOMAIN}.conf
```
## Server email support
See [debian manage](https://github.com/mickelindahl/debian_manage)

## Piwik
For setup with piwik se [link](https://github.com/mickelindahl/docker_piwik)

## Notes
- If only 1 port exposed, then that port is used. No need for setting environment varialbe `VIRTUAL_PORT`.
- With docker-compose.yml `version: "2"` one need to set network_mode: "bridge" for ut to work out of the box. 
Otherwise one need to add the compose network  to nginx see [https://docs.docker.com/compose/networking/](compose networking) 
and [jwilder/nginx](https://github.com/jwilder/nginx-proxy).
- If you get "502 Bad Gatway" after rebuilding an app one might need to delete the conf directory and 
recreate nginx container
- For nginx it is [important](https://support.dnsimple.com/articles/what-is-ssl-certificate-chain/) 
  that you use the fullchain.pem from letsencrypt for it to work properly in all browsers and devices. 
