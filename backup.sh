#!/bin/bash

cp="/bin/cp"
mv="/bin/mv"

DESTDIR=$1

function backup {
	PACKAGE_DIR=.
	FILE=$1
	
	# skip if source file not exists
	[ -f "$PACKAGE_DIR/$FILE" ] || return
	# create backup dir if missing
	BACKUP_DIR=$2
	[ -d "${BACKUP_DIR}" ] || mkdir -p "${BACKUP_DIR}"
	# compare source file with most recent backup 
	if [ -f "${BACKUP_DIR}/${FILE}" ]; then
		md5_orig=$(md5sum "$PACKAGE_DIR/$FILE" | cut -d " " -f1)
		md5_back=$(md5sum "$BACKUP_DIR/$FILE" | cut -d " " -f1)
		if [[ $md5_orig == $md5_back ]]; then
			# files are same, skip backup rotation
			echo "File $FILE not changed"
			return
		fi
	fi
	# roatate backups (preserve 2 older versions) 
	back1="${FILE}.1"; back2="${FILE}.2";	
	echo "Rotating backups for $FILE"
	if [ -f "${BACKUP_DIR}/$back1" ] ; then
		echo "... $back1 -> $back2" ; $mv -f "${BACKUP_DIR}/$back1" "${BACKUP_DIR}/$back2"
	fi
	if [ -f "${BACKUP_DIR}/${FILE}" ] ; then
		echo "... ${FILE} -> $back1" ; $mv -f "${BACKUP_DIR}/${FILE}" "${BACKUP_DIR}/$back1"
	fi
	echo "Backing up ${FILE}" ; $cp -f "$PACKAGE_DIR/$FILE" "${BACKUP_DIR}/${FILE}"
}

# backup /data/opendtu config.ini
backup config.ini $DESTDIR
