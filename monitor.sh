#!/bin/bash

CONTAINER=nginx

STATUS=$(docker inspect --format='{{.State.Status}}' $CONTAINER)

if [ $STATUS != "running" ]; then

  echo "Nginx is down restarting $STATUS"

  STATE=$(docker inspect --format='{{.State}}' $CONTAINER)

  if [ ! -f monitor.log ]; then
     touch monitor.log
  fi

  DATE=`date '+%Y-%m-%d %H:%M:%S'`

  echo "$DATE | $STATE" >> monitor.log

  docker start $CONTAINER

else

  echo "Nginx is up and running $STATUS"

fi
