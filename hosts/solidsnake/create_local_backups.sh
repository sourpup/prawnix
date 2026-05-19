#!/usr/bin/env bash

set -euxo pipefail

# Argument validation check
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <email-to-notify>"
    exit 1
fi

email=$1

trap 'backup_failed' ERR

backup_failed() {
	echo ERROR Sending failure email...
	echo "Subject: ERROR local borg run $(date) failed" | msmtp --file /data/backups/borg-msmtp.conf $email
}

# borrowed from
# https://github.com/NixOS/nixpkgs/pull/310199/files
borgWrapper () {
      local result
      borg "$@" && result=$? || result=$?
      if [[ "$result" == 1 ]]; then
        echo "ignoring warning return value 1"
        return 0
      else
        return "$result"
      fi
}

# first clean up any old generations
echo "Removing generations older than 15 days"
nix-collect-garbage --delete-older-than 15d

echo "Trying to mount local backup"
systemctl start mnt-local_backup.mount

# Ensure we have the source, and destinations drives mounted
echo "checking for /data, /mnt/local_backup mounts"
mount | rg "/data type btrfs" || exit 1
mount | rg "/mnt/local_backup type ext4" || exit 1

echo "mounts exist, starting backups..."

# General borg settings
## Archive name schema
DATE=$(date --iso-8601)-$(hostname)
BORG_OPTS="--stats --progress --compression zstd,10"

# BACKUP BOOT DRIVE TO /DATA
# repo created using:
# sudo bash # run as the root user
# BORG_BASE_DIR=/data/backups/borg-bootdrive-backup/basedir borg init --encryption=keyfile --storage-quota 220G /data/backups/borg-bootdrive-backup/repo
#
# then backup the borg key to a paper key like this
# BORG_BASE_DIR=/data/backups/borg-bootdrive-backup/basedir borg key export --paper  /data/backups/borg-bootdrive-backup/repo encrypted-key-backup.txt
REPO=/data/backups/borg-bootdrive-backup/repo
BORG_BASE_DIR=/data/backups/borg-bootdrive-backup/basedir
BORG_PASSCOMMAND="cat /data/backups/borg-bootdrive-backup/passphrase"
# DONT USE --one-file-system SINCE WE ARE ON BTRFS
echo Starting Backup for boot drive to $REPO
BORG_BASE_DIR=$BORG_BASE_DIR BORG_PASSCOMMAND=$BORG_PASSCOMMAND borgWrapper create $BORG_OPTS --exclude /home/eva/.cache --exclude /home/root/.cache --exclude /proc --exclude /tmp --exclude /dev --exclude /sys --exclude /mnt --exclude /data --exclude /media --exclude /run --exclude /var/log $REPO::boot_drive-$DATE /


# BACKUP /DATA TO /MNT/LOCAL_BACKUP
# repo created using:
# sudo bash # run as the root user
# BORG_BASE_DIR=/data/backups/borg-local-backup-basedir borg init --encryption=keyfile /mnt/local_backup/borg-backups
#
# then backup the borg key to a paper key like this
# BORG_BASE_DIR=/data/backups/borg-local-backup-basedir borg key export --paper  /mnt/local_backup/borg-backups encrypted-key-backup.txt
REPO=/mnt/local_backup/borg-backups
BORG_BASE_DIR=/data/backups/borg-local-backup-basedir
BORG_PASSCOMMAND="cat /data/backups/borg-local-backup-passphrase"

# /data targets
TARGETS=("docker" \
	 "documents" \
	 "media" \
	 "backups" \
	)

for target in ${TARGETS[*]}; do
	echo Starting Backup for $target to $REPO
	BORG_BASE_DIR=$BORG_BASE_DIR BORG_PASSCOMMAND=$BORG_PASSCOMMAND borgWrapper create $BORG_OPTS $REPO::$target-$DATE /data/$target
done


# unmounting now that we are done
systemctl stop mnt-local_backup.mount

echo Sending status email...
echo "Subject: local borg run $(date) complete" | msmtp --file /data/backups/borg-msmtp.conf $email
