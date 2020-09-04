#!/bin/bash
#############################################################
## Name          : mc-archive.sh
## Version       : 1.0
## Date          : 2012-09-16
## Author        : LHammonds
## Compatibility : Verified on Ubuntu Server 12.04 - 20.04
## Purpose       : Create archive of the Minecraft rsync copy.
## Run Frequency : Designed to run as needed.
## Exit Codes    :
##   0 = success
##   1 = lock file detected (same script already running)
##   2 = lock file detected (rsync script)
##   4 = archive creation failure
######################## CHANGE LOG #########################
## DATE       VER WHO WHAT WAS CHANGED
## ---------- --- --- ---------------------------------------
## 2012-09-16 1.0 LTH Created script.
#############################################################

## Import standard variables and functions. ##
source /var/scripts/common/standard.conf
source /var/scripts/common/mc.conf

LockFile="${TempDir}/mc-archive.lock"
RSYNCLockFile="${TempDir}/mc-sync.lock"
LogFile="${LogDir}/mc-archive.log"
ArchivePattern="_spigot.tar.7z"
ArchiveFile="`date +%Y-%m-%d-%H-%M`${ArchivePattern}"
RsyncFailure=0
ErrorFlag=0

#######################################
##            FUNCTIONS              ##
#######################################

function f_cleanup()
{
  if [ -f ${LockFile} ];then
    ## Remove lock file so other jobs can run.
    rm ${LockFile} 1>/dev/null 2>&1
  fi
  echo "`date +%Y-%m-%d_%H:%M:%S` [INFO] ${ScriptName} exit code: ${ErrorFlag}" >> ${LogFile}
}   ## f_cleanup()

#######################################
##           MAIN PROGRAM            ##
#######################################

if [ -d ${BackupDir}/spigot ]; then
  ## Make folder.
  mkdir -P ${BackupDir}/spigot
  chown root:root ${BackupDir}/spigot
  chmod 700 ${BackupDir}/spigot
fi

echo "`date +%Y-%m-%d_%H:%M:%S` [INFO] Archive started." | tee -a ${LogFile}

if [ -f ${RSYNCLockFile} ]; then
  # Lock file detected.  Abort script.
  echo "`date +%Y-%m-%d_%H:%M:%S` [SEVERE] Aborting script.  Rsync Lock file detected - ${LockFile}" | tee -a ${LogFile}
  exit 2
fi
if [ -f ${LockFile} ]; then
  # Lock file detected.  Abort script.
  echo "`date +%Y-%m-%d_%H:%M:%S` [SEVERE] Aborting script.  Lock file detected - ${LockFile}" | tee -a ${LogFile}
  exit 1
else
  echo "`date +%Y-%m-%d_%H:%M:%S` ${ScriptName}" > ${LockFile}
fi

echo "`date +%Y-%m-%d_%H:%M:%S` [INFO] Creating archive ${BackupDir}/spigot/${ArchiveFile}" | tee -a ${LogFile}
## Create archive of the recently sync'd backup folder.
tar -cpf - ${MCRootDir}/spigot | 7za a -si -mx=9 -w${TempDir} ${BackupDir}/spigot/${ArchiveFile} 1>/dev/null 2>&1
ReturnValue=$?
if [ ${ReturnValue} -ne 0 ]; then
  ## Fatal error detected.
  echo "`date +%Y-%m-%d_%H:%M:%S` [SEVERE] Failed to create archive. Return Code = ${ReturnValue}" | tee -a ${LogFile}
  echo "`date +%Y-%m-%d_%H:%M:%S` [SEVERE] Archive script aborted." | tee -a ${LogFile}
  ErrorFlag=4
else
  ## Record some stats to the log file.
  ArchiveSize=`ls -lh "${BackupDir}/spigot/${ArchiveFile}" | awk '{ print $5 }'`
  FolderSize=`du -sh ${MCRootDir}/spigot | awk '{ print $1 }'`
  echo "`date +%Y-%m-%d_%H:%M:%S` [INFO] ${MCRootDir}/spigot --> ${FolderSize}, compressed to ${ArchiveSize}" | tee -a ${LogFile}
  f_sendmsg "spigot" "say [INFO] Backup created. Archive size = ${ArchiveSize}"
fi
f_cleanup
exit ${ErrorFlag}
