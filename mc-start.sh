#!/bin/bash
#############################################################
## Name          : mc-start.sh
## Version       : 1.0
## Date          : 2012-09-16
## Author        : LHammonds
## Compatibility : Ubuntu Server 12.04 - 20.04 LTS
## Purpose       : Start Minecraft server
## Run Frequency : Designed to run every minute.
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
SRVDir="${MCRootDir}/spigot"
LogFile="${LogDir}/mc-start.log"
RAM2Use="3072M"
Owner="spigot"
Group="spigot"

## Check if server is running.
f_isrunning ${SRVSessionName}
SRVRunning=$?

if [ ${SRVRunning} -eq 1 ]; then
  ## Server is running. Do nothing and exit.
  echo "[INFO] Server is already running."
  exit 0
fi

if [ -f "${RebootFlag}" ]; then
  ## Server is set to reboot soon, do not start/restart services.
  echo "[WARN] Reboot flag detected.  Not starting Minecraft."
  exit 0
fi
## Startup server
cd ${SRVDir}
su ${Owner} --command "screen -d -m -S ${SRVSessionName} -t ${SRVSessionName} java -d64 -Xincgc -Xmx${RAM2Use} -jar ${SRVDir}/server.jar nogui"
echo "`date +%Y-%m-%d_%H:%M:%S` - [INFO] Server started." | tee -a ${LogFile}
exit 0
