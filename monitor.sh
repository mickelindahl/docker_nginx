#!/bin/bash

CONTAINER=nginx

STATUS=$(docker inspect --format='{{.State.Status}}' $CONTAINER)
STATUS2=$(docker exec  nginx true 2>/dev/null || echo "not running")

if [[ $STATUS != "running" ]] || [[ $STATUS2 = "not running" ]]; then

  echo "Nginx is down restarting $STATUS"

  STATE=$(docker inspect --format='{{.State}}' $CONTAINER)

  if [ ! -f monitor.log ]; then
     touch monitor.log
  fi

  DATE=`date '+%Y-%m-%d %H:%M:%S'`

  echo "$DATE | STATUS: $STATUS STATUS2: $STATUS2 STATE: $STATE" >> monitor.log

  docker start $CONTAINER

else

  echo "Nginx is up and running $STATUS"

fi
