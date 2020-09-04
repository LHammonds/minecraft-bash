#!/bin/bash
#############################################################
## Name          : mc-sync.sh
## Version       : 1.0
## Date          : 2012-09-16
## Author        : LHammonds
## Purpose       : Backup Minecraft to local folder (even if MC is running)
## Compatibility : Ubuntu Server 12.04 - 20.04 LTS
## Run Frequency : Designed to run as needed.
## Exit Codes    :
##   0 = success
##   1 = lock file detected (same script already running)
##   2 = rsync failure
######################## CHANGE LOG #########################
## DATE       VER WHO WHAT WAS CHANGED
## ---------- --- --- ---------------------------------------
## 2012-09-16 1.0 LTH Created script.
#############################################################

## Import standard variables and functions. ##
source /var/scripts/common/standard.conf
source /var/scripts/common/mc.conf

LockFile="${TempDir}/mc-sync.lock"
LogFile="${LogDir}/mc-sync.log"
MCDir="${MCRootDir}/spigot"
MCBakDir="${BackupDir}/spigot"
SRVSessionName="spigot"
RsyncFailure=0
ErrorFlag=0

#######################################
##            FUNCTIONS              ##
#######################################

function f_cleanup()
{
  if [ -f ${LockFile} ];then
    ## Remove lock file so other rsync jobs can run.
    rm ${LockFile} 1>/dev/null 2>&1
  fi
  echo "`date +%Y-%m-%d_%H:%M:%S` [INFO] ${ScriptName} exit code: ${ErrorFlag}" >> ${LogFile}
}   ## f_cleanup()

#######################################
##           MAIN PROGRAM            ##
#######################################

echo "`date +%Y-%m-%d_%H:%M:%S` [INFO] Sync started." | tee -a ${LogFile}

if [ -f ${LockFile} ]; then
  # Lock file detected.  Abort script.
  echo "`date +%Y-%m-%d_%H:%M:%S` [SEVERE] Aborting script.  Lock file detected - ${LockFile}" | tee -a ${LogFile}
  exit 1
else
  echo "`date +%Y-%m-%d_%H:%M:%S` ${ScriptName}" > ${LockFile}
fi

## Check if Minecraft is running.
f_isrunning "spigot"
MCRunning=$?
if [ ${MCRunning} -eq 1 ]; then
  ## An online backup must be performed while Minecraft is running.
  echo "`date +%Y-%m-%d_%H:%M:%S` [INFO] Minecraft is running." | tee -a ${LogFile}
  f_sendmsg spigot "say [INFO] Sync started"
  f_sendmsg spigot "save-off"
  f_sendmsg spigot "save-all"
  sleep 5
fi

## Sync files with local copy.
echo "`date +%Y-%m-%d_%H:%M:%S` [INFO] Sync files from ${MCDir} to ${MCBakDir}." | tee -a ${LogFile}
rsync -apogHK --delete --exclude=*.pid ${MCDir} ${MCBakDir} 1>/dev/null 2>&1
ReturnValue=$?
if [ ${ReturnValue} -ne 0 ]; then
  ## Fatal error detected.
  RsyncFailure=1
  echo "`date +%Y-%m-%d_%H:%M:%S` [SEVERE] Failed to sync ${MCDir} to ${MCBakDir}. Return Code = ${ReturnValue}" | tee -a ${LogFile}
  if [ ${MCRunning} -eq 1 ]; then
    ## Let online players know that backup failed.
    f_sendmsg "spigot" "say [SEVERE] Sync failed"
  fi
else
  ## Rsync completed without error.
  if [ ${MCRunning} -eq 1 ]; then
    ## Let online players know that backup completed.
    f_sendmsg "spigot" "say [INFO] Sync completed"
  fi
fi

## Record some stats to the log file.
MCSize=`du -sh ${MCDir} | awk '{ print $1 }'`
MCBakSize=`du -sh ${MCBakDir} | awk '{ print $1 }'`
echo "`date +%Y-%m-%d_%H:%M:%S` [INFO] ${MCDir} --> ${MCSize}" | tee -a ${LogFile}
echo "`date +%Y-%m-%d_%H:%M:%S` [INFO] ${MCBakDir} --> ${MCBakSize}" | tee -a ${LogFile}

if [ ${MCRunning} -eq 1 ]; then
  f_sendmsg "spigot" "save-on"
  f_sendmsg "spigot" "say [INFO] World size = ${MCBakSize}"
fi
if [ ${RsyncFailure} -eq 1 ]; then
  ## Abort script with failure code.
  echo "`date +%Y-%m-%d_%H:%M:%S` [SEVERE] Sync script aborted." | tee -a ${LogFile}
  ErrorFlag=2
fi

echo "`date +%Y-%m-%d_%H:%M:%S` [INFO] Sync completed." | tee -a ${LogFile}

f_cleanup
exit ${ErrorFlag}
