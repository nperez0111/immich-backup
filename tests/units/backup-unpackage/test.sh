#!/bin/bash

TEST_NAME="backup-unpackage"
TEST_EXTRACT_DIR="$(pwd)/${EXTRACT_DIR}/${TEST_NAME}"
TEST_TARGET_DIR="$(pwd)/${OUTPUT_DIR}/${TEST_NAME}"

FAILED_NUM=0

color yellow "Starting test case \"${TEST_NAME}\""

function prepare() {
    rm -rf "${TEST_EXTRACT_DIR}" "${TEST_TARGET_DIR}"
    mkdir -p "${TEST_EXTRACT_DIR}" "${TEST_TARGET_DIR}"
    sleep 0.5
}

function start() {
    docker run --rm \
        --mount "type=bind,source=${TEST_EXTRACT_DIR},target=${REMOTE_DIR}" \
        --mount "type=bind,source=${SOURCE_DIR},target=/immich/data/" \
        --mount "type=bind,source=${RCLONE_CONFIG_DIR},target=/config/" \
        -e "SOURCE_DIR=/immich/data/" \
        -e "RCLONE_REMOTE_DIR=${REMOTE_DIR}" \
        -e "BACKUP_FILE_SUFFIX=test" \
        "${DOCKER_IMAGE}" \
        backup
}

function test() {
    color blue "Testing..."

    ls -l "${TEST_EXTRACT_DIR}"

    docker run --rm \
        --mount "type=bind,source=${TEST_EXTRACT_DIR},target=/immich/source/" \
        --mount "type=bind,source=${TEST_TARGET_DIR},target=/immich/target/" \
        --mount "type=bind,source=${RCLONE_CONFIG_DIR},target=/config/" \
        -e "RCLONE_REMOTE_DIR=/immich/source/" \
        -e "SOURCE_DIR=/immich/source/" \
        -e "TARGET_DIR=/immich/target/" \
        "${DOCKER_IMAGE}" \
        restore

    check_files_same_in_folders "${TEST_TARGET_DIR}" "${TEST_EXTRACT_DIR}"
    if [[ $? != 0 ]]; then
        ((FAILED_NUM++))
    fi
}

prepare
start
test

test_result "${TEST_NAME}" "${FAILED_NUM}"
