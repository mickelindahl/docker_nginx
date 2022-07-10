#!/bin/bash

STOP_FILE="monitor.disabled"

############################################################
# Help                                                     #
############################################################
Help(){
  echo ""
  echo "Script checks if nxing server container is running. If not"
  echo "then it will restart the container"
  echo ""
  echo "Usage:"
  echo  "monitor.sh [COMMAND] [options]"
  echo "monitor.sh -h|-help"
  echo ""
  echo "Options":
  echo " -c, --clear-log       Clear logfile"
  echo " -h, --help            Display help text"
  echo " -m, --message MSG     Message to add to monitor log for a"
  echo "                       specific command"
  echo ""
  echo "Commands:"
  echo " run          Run montoring service"
  echo " disable      Will disable monitoring service and prevent"
  echo "              it from running until it is enabled again."
  echo " enable       Enable monitor service to be able to run again"
  echo ""
}
############################################################
############################################################
# CreateFile                                               #
############################################################
CreateFile(){

  PERMISSION=$1
  FILE=$2
  install -m 766 /dev/null $FILE


}
############################################################
############################################################
# Disable                                                  #
############################################################
Disable(){

  if [ -f $STOP_FILE ];then
    echo "Monitor already disabled"
    exit
  fi

  # "Create file with read write permission for all"
  CreateFile 766 $STOP_FILE

  MSG=$1
  Log "Disable monitor" "$MSG"

}
############################################################
############################################################
# Enable                                                   #
############################################################
Enable(){

  if [ ! -f $STOP_FILE ];then
    echo "Monitor already enabled"
    exit
  fi

  rm $STOP_FILE

  MSG=$1
  Log "Enable monitor" "$MSG"

}
###########################################################
############################################################
# Log                                                   #
############################################################
Log(){

  PROMPT=$1
  MSG=$2

  DATE=`date '+%Y-%m-%d %H:%M:%S'`

  LOG="$DATE | $PROMPT"

  if [ ! -z "$MSG" ];then
    LOG="$LOG | MSG: $MSG"
  fi

  echo $LOG >> monitor.log

}
###########################################################
############################################################
# Run                                                      #
############################################################
Run(){

  MSG=$1

  if [ -f $STOP_FILE ];then
    echo "Monitor disbled. Please run 'monitor.sh enable'"
    exit
  fi

  CONTAINER=nginx

  DATE=`date '+%Y-%m-%d %H:%M:%S'`

  STATUS=$(docker inspect --format='{{.State.Status}}' $CONTAINER)
  STATUS2=$(docker exec  nginx true 2>/dev/null || echo "not running")

  # STATUS2="not running"

  if [[ $STATUS != "running" ]] || [[ $STATUS2 = "not running" ]]; then

    echo "Container $CONTAINER is down restarting $STATUS"

    STATE=$(docker inspect --format='{{json .State}}' $CONTAINER)

    PROMPT="Run monitor | STATUS: $STATUS | STATUS2: $STATUS2 |  STATE: $STATE"
    Log "$PROMPT" "$MSG"

    docker start $CONTAINER

  else

    echo "Container $CONTAINER is up and running $STATUS"

  fi
}
###########################################################
###########################################################
# Main program                                             #
############################################################
############################################################

# When you run shift, the current positional parameters are 
# shifted left n times.
#CMD=$1; shift;
#OPTIND=1

# NOTE: One of the many things that getopt does while parsing options is to 
# rearrange the arguments, so that non-option arguments come last, and 
# combined short options are split up. 
# NOTE: This requires GNU getopt.  On Mac OS X and FreeBSD, you have to install this
# separately; see below. 
TEMP=$(getopt -o chm: --long clear-log,help,message: -n 'javawrap' -- "$@")

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# NOTE: So, TEMP contains the rearranged, quoted, split-up options, 
# and using eval set makes them script arguments.
# NOTE: The quotes around '$TEMP': they are essential!
eval set -- "$TEMP"

MSG=
while true; do
  # echo "Current positional argument: $1"
  case "$1" in
    -c | --clear-log ) rm monitor.log; shift ;;
    -h | --help ) Help; exit;;
    -m | --message ) MSG="$2"; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

CMD=$1;

if [ ! -f monitor.log ]; then
   CreateFile 766 monitor.log
fi

case $CMD in
   disable) # Run monitoring service 
     Disable "$MSG"
     exit;;
   enable) # Run monitoring service 
     Enable "$MSG"
     exit;;
   run) # Run monitoring service 
     Run "$MSG"
     exit;;
   "") # Display help with no command 
     Help
     exit;;
   *) # Invalid comman
         echo "Error: Invalid comman '$CMD'"
         exit;;
esac
