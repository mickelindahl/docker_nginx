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
  echo  "monitor.sh [options] [COMMAND]"
  echo "monitor.sh -h|--help"
  echo ""
  echo "Options":
  echo " -h, --help             Display help text"
  echo " -m, --message MSG      Message to add to monitor log for a" 
  echo "                        specific command"
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
# Disable                                                  #
############################################################
Disable(){

  if [ -f $STOP_FILE ];then
    echo "Monitor already disabled"
    exit
  fi

  MSG=$1
  DATE=`date '+%Y-%m-%d %H:%M:%S'`

  touch $STOP_FILE

  LOG="$DATE | Disable monitor"

  if [ ! -z $MSG ];then
    LOG="$LOG | MSG: $MSG"
  fi

  echo $LOG >> monitor.log
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

  MSG=$1
  DATE=`date '+%Y-%m-%d %H:%M:%S'`

  rm $STOP_FILE

  LOG="$DATE | Enable monitor"

  if [ ! -z $MSG ];then
    LOG="$LOG | MSG: $MSG"
  fi

  echo $LOG >> monitor.log

}
###########################################################
############################################################
# Run                                                      #
############################################################
Run(){

  if [ -f $STOP_FILE ];then
    echo "Monitor disbled. Please run 'monitor.sh enable'"
    exit
  fi

  CONTAINER=nginx

  DATE=`date '+%Y-%m-%d %H:%M:%S'`

  STATUS=$(docker inspect --format='{{.State.Status}}' $CONTAINER)
  STATUS2=$(docker exec  nginx true 2>/dev/null || echo "not running")

  if [[ $STATUS != "running" ]] || [[ $STATUS2 = "not running" ]]; then

    echo "Container $CONTAINER is down restarting $STATUS"

    STATE=$(docker inspect --format='{{.State}}' $CONTAINER)

    if [ ! -f monitor.log ]; then
      touch monitor.log
    fi

    echo "$DATE | STATUS: $STATUS | STATUS2: $STATUS2 |  STATE: $STATE" >> monitor.log

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


# Get the options
while getopts ":h" option; do
   case $option in
      h/help) # display Help
         Help
         exit;;
      m/message) # add message
         MSG=$OPTARG
         exit;;
      \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

CMD=$1

case $CMD in
   disable) # Run monitoring service 
     Disable $MSG
     exit;;
   enable) # Run monitoring service 
     Enable $MSG
     exit;;
   run) # Run monitoring service 
     Run $MSG
     exit;;
   "") # Display help with no command 
     Help
     exit;;
   *) # Invalid comman
         echo "Error: Invalid comman '$CMD'"
         exit;;
esac
