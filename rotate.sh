#!/bin/bash

export PATH=/bin:/usr/bin:/usr/local/bin

############################## VARS ############################
# Vars
## Last number of days to return, it's based on mtime
## For example if you put 10, it will delete the files older than 10 days
RETAIN_DAYS=10

# CyberPanel vhosts directory path
VHOSTS_DIR="/usr/local/lsws/conf/vhosts/"

# Backup status string that CyberPanel writes after successfull backups
BACKUP_STATUS_SUCCESS_STRING="Completed"

# CyberPanel backup files extension
BACKUP_FILES_EXTENSION_PATTERN="backup-*.tar.gz"
################################################################

# Loop through the vhosts to get their backup dir
for ACCT_NAME in $(ls $VHOSTS_DIR |grep -v Example) ; do
	USER_BACKUP_PATH="/home/$ACCT_NAME/backup/"

	# Check backup status before doing the rotation
	if [ ! -z ${USER_BACKUP_PATH} ] && [ -d ${USER_BACKUP_PATH} ]; then
		status_file="${USER_BACKUP_PATH}/status"
		
		# Check the status is success from the status file
		if grep -Fxq "$BACKUP_STATUS_SUCCESS_STRING" $status_file ; then

			# If success, check the number of backup files there
			# and make sure they are greater than RETAIN_DAYS var
			NUMBER_OF_BKP_FILES="$(ls $USER_BACKUP_PATH | wc -l)"
			if [ "$NUMBER_OF_BKP_FILES" -gt "$RETAIN_DAYS" ]; then

				# If the NUMBER_OF_BKP_FILES is greather than RETAIN_DAYS, Let's rotate
				if [ ! -z ${USER_BACKUP_PATH} ] && [ -d ${USER_BACKUP_PATH} ]; then
					cd ${USER_BACKUP_PATH}
					find . -type f -name "${BACKUP_FILES_EXTENSION_PATTERN}" -mtime +${RETAIN_DAYS} -exec rm {} \;
				fi

			fi

		fi
	fi

done
