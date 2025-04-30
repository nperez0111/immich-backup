#!/bin/bash

. /app/includes.sh

# backup immich to all remotes
function immich_backup() {
    local HAS_ERROR="FALSE"

    for RCLONE_REMOTE_X in "${RCLONE_REMOTE_LIST[@]}"; do
        color blue "upload backup file to storage system $(color yellow "[${RCLONE_REMOTE_X}]")"

        rclone ${RCLONE_GLOBAL_FLAG} copy "${SOURCE_DIR}" "${RCLONE_REMOTE_X}"
        if [[ $? != 0 ]]; then
            color red "upload to ${RCLONE_REMOTE_X} failed"

            HAS_ERROR="TRUE"
        fi
    done

    if [[ "${HAS_ERROR}" == "TRUE" ]]; then
        send_notification "failure" "File upload failed at $(date +"%Y-%m-%d %H:%M:%S %Z")."

        exit 1
    fi
}

color blue "running the backup program at $(date +"%Y-%m-%d %H:%M:%S %Z")"

# Initialize environment variables from includes.sh and check required ones
init_env

send_notification "start" "Start Immich backup at $(date +"%Y-%m-%d %H:%M:%S %Z")"

# Check rclone connection - check_rclone_connection likely checks all in the list
check_rclone_connection any

# Perform the Immich backup (SOURCE_DIR) to all remotes
immich_backup

# Send success notification
# Message assumes success if we reach here (errors in backup_immich cause exit)
send_notification "success" "Immich backup successfully completed and uploaded to all remotes at $(date +"%Y-%m-%d %H:%M:%S %Z")."

color none ""
