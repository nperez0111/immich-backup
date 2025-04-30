#!/bin/bash

. /app/includes.sh

function restore_db_postgresql() {
    color blue "attempting to restore immich db"

    pg_restore -h "${PG_HOST}" -p "${PG_PORT}" -d "${PG_DBNAME}" -U "${PG_USERNAME}" -c "${RESTORE_FILE_DB}"

    if [[ $? == 0 ]]; then
        color green "restore immich db successful"
    else
        color red "restore immich db failed"
    fi
}

function immich_restore() {
    # Check if upload location exists/is accessible
    if [[ ! -e "${TARGET_DIR}" ]]; then
        color red "upload directory not found"
        send_notification "failure" "File restore failed at $(date +"%Y-%m-%d %H:%M:%S %Z"). Reason: Upload directory not found."
        exit 1
    fi

    # Get first remote from list
    local RCLONE_REMOTE="${RCLONE_REMOTE_LIST[0]}"

    color blue "downloading backup from storage system $(color yellow "[${RCLONE_REMOTE}]") and restore to ${TARGET_DIR}"

    rclone ${RCLONE_GLOBAL_FLAG} copy "${RCLONE_REMOTE}" "${TARGET_DIR}"

    if [[ $? != 0 ]]; then
        color red "download from ${RCLONE_REMOTE} failed"
        send_notification "failure" "File restore failed at $(date +"%Y-%m-%d %H:%M:%S %Z")."
        exit 1
    fi
}

# immich_restore
# TODO: restore immich db
# restore_db_postgresql
