#!/bin/bash
#############################################################
## Name          : mc-build.sh
## Version       : 1.0
## Date          : 2020-05-17
## Author        : LHammonds
## Compatibility : Ubuntu Server 18.04 - 20.04 LTS
## Purpose       : Start Minecraft server
## Run Frequency : Designed to run as needed.
## Exit Codes    : None
######################## CHANGE LOG #########################
## DATE       VER WHO WHAT WAS CHANGED
## ---------- --- --- ---------------------------------------
## 2020-05-17 1.0 LTH Created script.
#############################################################

## Import standard variables and functions. ##
source /var/scripts/common/standard.conf
source /var/scripts/common/mc.conf

BuildDir="${MCRootDir}/build"
SRVDir="${MCRootDir}/spigot"
MCVer="1.16.2"
LogFile="${LogDir}/mc-build.log"
Owner="spigot"
Group="spigot"

## Build server
echo "`date +%Y-%m-%d_%H:%M:%S` - [INFO] Build started for ${MCVer}." | tee -a ${LogFile}
cd ${BuildDir}
wget https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
java -jar BuildTools.jar --rev ${MCVer}
echo "`date +%Y-%m-%d_%H:%M:%S` - [INFO] Build finished for ${MCVer}." | tee -a ${LogFile}
chown spigot:spigot spigot-${MCVer}.jar
mv ${BuildDir}/spigot-${MCVer}.jar ${SRVDir}/server-new.jar
echo "`date +%Y-%m-%d_%H:%M:%S` - [INFO] Stopping old server." | tee -a ${LogFile}
${ScriptDir}/prod/mc-stop.sh
echo "`date +%Y-%m-%d_%H:%M:%S` - [INFO] Swapping server files." | tee -a ${LogFile}
rm ${SRVDir}/server-old.jar
mv ${SRVDir}/server.jar ${SRVDir}/server-old.jar
mv ${SRVDir}/server-new.jar ${SRVDir}/server.jar
echo "`date +%Y-%m-%d_%H:%M:%S` - [INFO] Starting new server." | tee -a ${LogFile}
${ScriptDir}/prod/mc-start.sh
exit 0
