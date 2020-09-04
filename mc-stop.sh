#!/bin/bash
#############################################################
## Name          : mc-stop.sh
## Version       : 1.0
## Date          : 2012-09-16
## Author        : LHammonds
## Compatibility : Ubuntu Server 12.04 - 20.04
## Purpose       : Stop the Minecraft server.
## Run Frequency : Once per day or as needed.
## Exit Codes    : None
######################## CHANGE LOG #########################
## DATE       VER WHO WHAT WAS CHANGED
## ---------- --- --- ---------------------------------------
## 2012-09-16 1.0 LTH Created script.
#############################################################

## Import standard variables and functions. ##
source /var/scripts/common/standard.conf
source /var/scripts/common/mc.conf

SRVSessionName="spigot"
LogFile="/var/log/mc-stop.log"
LockFile="/tmp/mc-reboot.lock"
Owner="spigot"
Group="spigot"

#######################################
##            FUNCTIONS              ##
#######################################

function f_cleanup()
{
  if [ -f ${LockFile} ];then
    ## Remove lock file so subsequent jobs can run.
    rm ${LockFile} 1>/dev/null 2>&1
  fi
}

#######################################
##           MAIN PROGRAM            ##
#######################################

echo "`date +%Y-%m-%d_%H:%M:%S` [INFO] Shutdown started." | tee -a ${LogFile}

if [ -f ${LockFile} ]; then
  # Lock file detected.  Abort script.
  echo "`date +%Y-%m-%d_%H:%M:%S` [SEVERE] Aborting script.  Lock file detected - ${LockFile}" | tee -a ${LogFile}
  exit 1
else
  echo "`date +%Y-%m-%d_%H:%M:%S` ${ScriptName}" > ${LockFile}
fi

## Check if server is running.
f_isrunning ${SRVSessionName}
SRVRunning=$?

if [ ${SRVRunning} -eq 1 ]; then
  ## Inform players of a pending reboot.
  echo "`date +%Y-%m-%d_%H:%M:%S` [INFO] Notifying users about shutdown." | tee -a ${LogFile}
  f_sendmsg "say [WARNING] Server shutdown in 5 minutes"
  sleep 60
  f_sendmsg "say [WARNING] Server shutdown in 4 minutes"
  sleep 60
  f_sendmsg "say [WARNING] Server shutdown in 3 minutes"
  sleep 60
  f_sendmsg "say [WARNING] Server shutdown in 2 minutes"
  sleep 60
  f_sendmsg "say [WARNING] Server shutdown in 1 minute"
  sleep 30
  f_sendmsg ${SRVSessionName} "say [WARNING] Server shutdown in 30 seconds"
  sleep 15
  f_sendmsg ${SRVSessionName} "say [WARNING] Server shutdown in 15 seconds"
  sleep 5
  f_sendmsg ${SRVSessionName} "say [WARNING] Server shutdown in 10 seconds"
  sleep 5
  f_sendmsg ${SRVSessionName} "say [WARNING] Server shutdown in 5"
  sleep 1
  f_sendmsg ${SRVSessionName} "say [WARNING] Server shutdown in 4"
  sleep 1
  f_sendmsg ${SRVSessionName} "say [WARNING] Server shutdown in 3"
  sleep 1
  f_sendmsg ${SRVSessionName} "say [WARNING] Server shutdown in 2"
  sleep 1
  f_sendmsg ${SRVSessionName} "say [WARNING] Server shutdown in 1"
  f_sendmsg ${SRVSessionName} "save-all"
  f_sendmsg ${SRVSessionName} "stop"
  sleep 5
fi
f_cleanup
echo "`date +%Y-%m-%d_%H:%M:%S` [INFO] Shutdown completed." | tee -a ${LogFile}
## Flush file system buffers.
sync
