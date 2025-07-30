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
	echo "Subject: ERROR remote borg run $(date) failed" | msmtp --file /data/backups/borg-msmtp.conf $email
}


# Ensure we have the source drive mounted
echo "checking for /data mount"
mount | rg "/data type btrfs" || exit 1

# Ensure we haven't gone read only
btrfs property get -ts /data | rg "ro=false" || exit 1

echo "mounts exist, starting backups..."

# General borg settings
## Archive name schema
DATE=$(date --iso-8601)-$(hostname)
BORG_OPTS="--stats --progress --compression zstd,10"

# remote-borg-server is defined in /root/.ssh/config to point to our remote borg server, and to use the right ssh key
# like this:
    # Host remote-borg-server
    # Hostname borg.host.com
    # Port 2222
    # User borg
    # IdentityFile /blah/.ssh/id_ed25519_borg

REPO=remote-borg-server:/backup/solidsnake/remote_backup
BORG_BASE_DIR=/data/backups/borg-remote-backup-basedir
BORG_PASSCOMMAND="cat /data/backups/borg-remote-backup-passphrase"

# /data targets
# TARGETS=("docker" \
# 	 "documents" \
# 	 "media" \
# 	 "backups" \
# 	)

#TODO REMOTE: TESTING
TARGETS=( "backups" )

for target in ${TARGETS[*]}; do
	echo Starting Backup for $target to $REPO
	BORG_BASE_DIR=$BORG_BASE_DIR BORG_PASSCOMMAND=$BORG_PASSCOMMAND borg create $BORG_OPTS $REPO::$target-$DATE /data/$target
done


echo Sending status email...
echo "Subject: remote borg run $(date) complete" | msmtp --file /data/backups/borg-msmtp.conf $email
