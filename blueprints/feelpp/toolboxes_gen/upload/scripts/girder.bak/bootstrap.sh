#!/bin/bash -l
# This script introduces functions to maniputate girder data server REST API,
# using curl.
# Curl will fail with exit status different from 0.
# See https://curl.haxx.se/libcurl/c/libcurl-errors.html for more debug info.
# Custom logs are available on the machine ${HOME} directory in the LOG_FILE
# set bellow.

set -euo pipefail
set -x

# Custom logs
LOG_FILE=$0.log
WORK_DIR=$1
SIMG=$2
GIRDER_REPO_URL=$3
GIRDER_FOLDER_ID=$4
GIRDER_API_KEY="${5:-unknown}"
NO_ERASE=$6

# Prepare directories if they do not exists.
mkdir -p ${WORK_DIR}/feel
mkdir -p ${WORK_DIR}/singularity_images
WORK_DIR=${WORK_DIR}/singularity_images

# Download jq JSON parsing tool (if not available) to parse HTTP request response
# if not available on the machine.
jq_parser()
{
    JQ=`if command -v jq >/dev/null 2>&1; then echo "jq"; fi`
    if [ -z $JQ ]; then
        echo "Downloading 'jq' tool."
        if [ ! -f ${WORK_DIR}/jq ]; then
            curl -f --show-error --progress-bar -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -o ${WORK_DIR}/jq
        fi
        chmod 755 ${WORK_DIR}/jq
        JQ=${WORK_DIR}/jq
        echo "using jq: $JQ"
    fi
    export JQ
}

# Get the girder item ID.
girder_simg_get_id()
{
    GIRDER_REST_URL="${GIRDER_REPO_URL}/api/v1/item?folderId=${GIRDER_FOLDER_ID}&name=${SIMG}&limit=50&sort=lowerName&sortdir=1"
    echo "Request: ${GIRDER_REST_URL}" >> ${LOG_FILE}
    GIRDER_ITEM_INFO=`curl -s -f --show-error -X GET --header 'Accept: application/json' \
        --header 'Accept: application/json' \
        "${GIRDER_REST_URL}" 2>> ${LOG_FILE} `
    GIRDER_ITEM_ID=`echo $GIRDER_ITEM_INFO | ${JQ} -rc '.[]._id'`
    export GIRDER_ITEM_ID
}

# Get the girder file associated to the girder item ID.
girder_simg_download()
{
    GIRDER_REST_URL="${GIRDER_REPO_URL}/api/v1/item/${GIRDER_ITEM_ID}/download?contentDisposition=attachment"
    echo "Request: ${GIRDER_REST_URL}" >> ${LOG_FILE}
    curl -f --show-error --progress-bar -d "${GIRDER_CREDENTIALS}" -X GET --header 'Accept: application/json' \
        --header 'Accept: application/json' \
        "${GIRDER_REST_URL}" \
        -o ${WORK_DIR}/${SIMG} 2>> ${LOG_FILE}
}

echo "MSO4SC Orchestrator bootstrap logs" > ${LOG_FILE}
date >> ${LOG_FILE}
printf '*%.0s' {1..60} >> ${LOG_FILE}
echo "" >> ${LOG_FILE}

if [ ! -f ${WORK_DIR}/${SIMG} ]; then
    jq_parser
    echo "GIRDER get item id" >> ${LOG_FILE}
    girder_simg_get_id
    echo "GIRDER download item file" >> ${LOG_FILE}
    girder_simg_download
else
    echo "Bootstrap will use ${WORK_DIR}/${SIMG} singularity image!" >> ${LOG_FILE}
fi
