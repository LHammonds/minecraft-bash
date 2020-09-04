#!/bin/bash
#############################################################
## Name          : mc-purge.sh
## Version       : 1.0
## Date          : 2012-09-16
## Author        : LHammonds
## Compatibility : Ubuntu Server 12.04 - 20.04 LTS
## Purpose       : Delete old backup files based on number of files to keep.
## Run Frequency : Can run as often as needed.
## Exit Codes    : None
######################## CHANGE LOG #########################
## DATE       VER WHO WHAT WAS CHANGED
## ---------- --- --- ---------------------------------------
## 2012-09-16 1.0 LTH Created script.
#############################################################

## Import standard variables and functions. ##
source /var/scripts/common/standard.conf
source /var/scripts/common/mc.conf

LogFile="${LogDir}/mc-purge.log"
ArchivePattern="_spigot.tar.7z"

## FilesToKeep is the amount of archives to keep at any time.
FilesToKeep=10
Count=0

echo "`date +%Y-%m-%d_%H:%M:%S` ${0} [INFO] Purge started. FilesToKeep=${FilesToKeep}" | tee -a ${LogFile}

for Filename in `ls -t ${ShareDir}/*${ArchivePattern}`
do
  if [ ${Count} -lt ${FilesToKeep} ]; then
    ## Do nothing for the 1st amount of files.
    echo "Skipping ${Filename}" | tee -a ${LogFile}
  else
    ## Files greater than the amount indicated need to be deleted.
    echo "Deleting ${Filename}" | tee -a ${LogFile}
    rm ${Filename}
  fi
  Count=$((${Count} + 1))
done
echo "`date +%Y-%m-%d_%H:%M:%S` ${0} [INFO] Purge completed." | tee -a ${LogFile}
