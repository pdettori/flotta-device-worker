#!/bin/bash

SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"

###############################################################################################
#               Functions
###############################################################################################

set_home() {
  echo ${PROJECT_HOME} | grep flotta-device-worker > /dev/null
  if [ "$?" -ne 0 ]; then 
    echo "not running in context"
    YGGD_HOME=${HOME}/.yggd
    PROJECT_HOME=${HOME}
    IN_CTX=false
  else  
    echo "running in context"
    YGGD_HOME=${PROJECT_HOME}/.yggd
  fi  
}

delete_dir() {
  rm -rf ${PROJECT_HOME}/.yggd
  sudo rm -rf /var/local/yggdrasil/device
}

delete_commands() {
  sudo rm /usr/local/bin/node_exporter
  sudo rm /usr/local/bin/yggd
  sudo rm  /usr/local/libexec/yggdrasil/device-worker
}

stop_system_services() {
   systemctl is-active --quiet yggd.service
   if [ "$?" -eq 0 ]; then
    sudo systemctl stop yggd.service
   fi

   systemctl is-active --quiet node_exporter.service
   if [ "$?" -eq 0 ]; then
    sudo systemctl stop node_exporter.service
   fi
}

disable_system_services() {
  sudo systemctl disable yggd.service
  sudo systemctl disable node_exporter.service

}

remove_system_services() {
  sudo rm /etc/systemd/system/yggd.service
  sudo rm /etc/systemd/system/node_exporter.service
  sudo systemctl daemon-reload
  sudo systemctl reset-failed
}


###########################################################################################
#                   Main   
###########################################################################################

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "running on macOS"
  if [ "$SSH_CMD" == "" ]; then
    echo "Env var SSH_CMD must be set"
    exit -1
  fi
  $SSH_CMD 'bash -s' < ${SCRIPT_HOME}/delete-agent.sh "$@"
  exit 0
fi  

# handle linux remote to linux
if [ "$SSH_CMD" != "" ]; then
  $SSH_CMD 'bash -s' < ${SCRIPT_HOME}/delete-agent.sh "$@"
  exit 0
fi

set_home

stop_system_services

disable_system_services

remove_system_services

delete_dir

delete_commands

