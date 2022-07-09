#!/bin/bash
##########################################################
# AddHtmlPages                                         #
##########################################################
##########################################################
addHtmlPages(){
  if [ ! -d html ]; then
    mkdir -p html
  fi

  cp 50x.html html/50x.html
  cp 50x.html html/503.html
  cp index.html html/index.html
}
###########################################################
###########################################################
# CheckUserIsRoot                                         #
###########################################################
###########################################################
CheckUserIsRoot(){

  USER=$1

  if [ $USER != root ]; then
    echo "Please run as root"
    exit
  fi
}
############################################################
############################################################
# Help                                                     #
############################################################
Help(){
  echo ""
  echo "Script checks if nxing server container is running. If not"
  echo "then it will restart the container"
  echo ""
  echo "Usage:"
  echo  "install.sh [options]"
  echo "monitor.sh -h|-help"
  echo ""
  echo "Options":
  echo " --default-domain      Use cert from this domain to create"
  echo "                       default domains for the server"
  echo " -h, --help            Display help text"
  echo " --mailto              Add cron mailto to specified adress"
  echo " --no-reinstall        Do not create reinstall script"
  echo ""
}
############################################################
############################################################
# InstallCron                                              #
############################################################
############################################################
InstallCron(){

  PATH_CRON=$1
  MAILTO=$2

  echo "Installing nginx-cron in $PATH_CRON"
  cp sample.nginx-cron $PATH_CRON/nginx-cron
  sed -i "s#{path-nginx}#$(pwd)#g" $PATH_CRON/nginx-cron

  echo "Installing monitor-cron in $PATH_CRON"
  cp sample.monitor-cron $PATH_CRON/nginx-monitor-cron
  sed -i "s#{src}#$(pwd)#g" $PATH_CRON/nginx-monitor-cron

  if [ ! -z "$MAILTO" ];then
    sed  -i '1i MAILTO="'$MAILTO'"' $PATH_CRON/nginx-cron
  fi
}
########################################################
########################################################
# Main program                                         #
########################################################

CheckUserIsRoot "$USER"

echo "Date: "`date`

ARGS="$@"
TEMP=$(getopt -o hm: --long default-domain:,help,mailto:,no-reinstall -n 'javawrap' -- "$@")
eval set -- "$TEMP"

DEFAULT_DOMAIN=
MAILTO=
REINSTALL=true
while true; do
  # echo "Current positional argument: $1"
  case "$1" in
    --default-domain ) DEFAULT_DOMAIN="$2"; shift 2 ;;
    -h | --help ) Help; exit;;
    --mailto ) MAILTO="$2"; shift 2;;
    --no-reinstall ) REINSTALL=false; shift;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

./monitor.sh disable -m  "Install nginx start"

NETWORK=nginx

#if [ ! $USER==root ]; then
#    echo "Please run as root"
#    exit
#fi

#DEFAULT_DOMAIN=$1

#echo "DEFAULT_DOMAIN: ${DEFAULT_DOMAIN}"

echo "$MAILTO!!!!!!"

InstallCron "/etc/cron.d" "$MAILTO"

#cp sample.monitor-cron monitor-cron

#sed -i "s#{src}#$(pwd)#g" monitor-cron
#mv monitor-cron /etc/cron.d/nginx-monitor-cron

echo "Remove old conf"
rm -r conf/conf.d
rm -r conf/certs

echo "Create directories"
if [ ! -d conf/vhost ]; then
  mkdir -p conf/vhost.d
fi
mkdir -p conf/conf.d
mkdir -p conf/certs

echo "Copy added.conf"
cp added.conf ./conf/conf.d/added.conf
#cp nginx-error.conf ./conf/vhost.d/whiteboard.greencargo.com
#cp nginx-error.conf ./conf/conf.d/nginx-error.conf

addHtmlPages

# Error pages
#if [ ! -d html ]; then
#  mkdir -p html
#fi

#cp 50x.html html/50x.html
#cp 50x.html html/503.html
#cp index.html html/index.html

if [ -f redirects.conf ]; then

  echo "Copy redirect.conf"
  cp redirects.conf ./conf/conf.d/redirects.conf

fi

echo "Create compose file"
cp sample.docker-compose.yml docker-compose.yml

if [ -f virtual-hosts-local ]; then

  # Greencargo specific config
  if [ -f  local-certs/greencargo.com.crt ]; then
     VIRTUAL_HOSTS_LOCAL=`cat virtual-hosts-local | tr '\n' ' '`
     for host in $VIRTUAL_HOSTS_LOCAL; do

        echo "Adding cert and key for local  $host"
        cp ./local-certs/greencargo.com.crt conf/certs/$host.crt
        cp ./local-certs/greencargo.com.key conf/certs/$host.key

     done

     # Create default certs used for 503 page
     cp ./local-certs/greencargo.com.crt conf/certs/default.crt
     cp ./local-certs/greencargo.com.key conf/certs/default.key

   fi
elif [ -f virtual-hosts ]; then

  echo "Create virtual host certificates"

  VIRTUAL_HOSTS=`cat virtual-hosts | tr '\n' ' '`
  for host in $VIRTUAL_HOSTS; do

     ./add_certificate.sh $host

  done

  echo "Create copy all certs script"
  cp sample.copy_all_certs.sh copy_all_certs.sh

  sed -i "s#{path-nginx}#$(pwd)#g" copy_all_certs.sh

  ./copy_all_certs.sh

  #./install_cron.sh

  #echo "$DEFAULT_DOMAIN"
  #[ -z "$DEFAULT_DOMAIN" ] && echo "Empty 1"
  #[ -z $DEFAULT_DOMAIN ] && echo "Empty 2"
  #[ -z "" ] && echo "Empty 3"

  if [[ ! -z $DEFAULT_DOMAIN ]]; then

       echo "Create default certs used for 503 page"
       cp conf/certs/${DEFAULT_DOMAIN}.crt conf/certs/default.crt
       cp conf/certs/${DEFAULT_DOMAIN}.key conf/certs/default.key

   else

     echo "No deafult domain skipping"

   fi
else

  echo "Missing files in  virtual-hosts or virtual-hosts-local files"
  echo "This means that the server will not have ssh certificates"
  read -p "Continue (Y/n)?" choice
  case "$choice" in
       n|N ) exit ;;
       * ) echo "Continue" ;;
  esac

fi

if [ -f nginx-piwik.env ]; then

   export $(cat nginx-piwik.env | xargs)

   for arg in "PIWIK_PATH_HTML"; do

        if [ "${!arg}" = "" ];then
            echo "Missing env $arg in piwik.env"
            exit 1
        fi

   done

   sed -i "s#{piwik-path-html}#- $PIWIK_PATH_HTML:/var/www/html#g" docker-compose.yml

else

   echo "Missing piwik configuration. Removing option from docker-compose"
   sed -i "s#{piwik-path-html}##g" docker-compose.yml

fi

# Missing from sample.docker-compose.yml
#sed -i "s#{http-proxy}#$http_proxy#g" docker-compose.yml
#sed -i "s#{https-proxy}#$https_proxy#g" docker-compose.yml

TMP=`docker network ls | grep $NETWORK`
if [ -z "$TMP" ]; then
   echo "Create external network"
   docker network create -d bridge $NETWORK
fi

echo "Stop and remove old instances"
docker-compose stop
docker-compose rm -f

echo "Start"
docker-compose --compatibility up -d

./monitor.sh enable -m  "Install nginx end"

if [ "$REINSTALL" = true ];then
  echo "./install.sh $ARGS --no-reinstall" > reinstall.sh
  chmod 755 reinstall.sh
  echo ""
  echo "Installtion of nginx server done!"
  echo ""
  echo "You can now run './reinstall.sh' to reinstall server when needed"
  echo ""
else
  echo ""
  echo "Nginx server resinstalled"
  echo ""
fi
