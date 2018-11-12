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
GIRDER_API_KEY=$5
NO_ERASE=$6
MODULES=$7
MODEL_PARAM_STR=$8
MODEL_PARAM_ARR= ( ${MODEL_PARAM_STR} )


# Prepare directories if they do not exists.
mkdir -p ${WORK_DIR}/feel
mkdir -p ${WORK_DIR}/singularity_images
mkdir -p ${WORK_DIR}/data
SIMG_DIR=${WORK_DIR}/singularity_images

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

# Create a token from GIRDER_API_KEY. This function set two variables
# GIRDER_CREDENTIALS_FILE
# GIRDER_TOKEN
# This function does not create a new token if a token exist. (use girder_token_delete)
girder_token_create()
{
    GIRDER_REST_URL="${GIRDER_REPO_URL}/api/v1/api_key/token?key=${GIRDER_API_KEY}&duration=1"
    GIRDER_CREDENTIALS=`curl -s -d '' -f --show-error -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' "${GIRDER_REST_URL}" 2>> "${LOG_FILE}"`
    GIRDER_TOKEN=`echo "${GIRDER_CREDENTIALS}" | ${JQ} -rc .authToken.token`
    echo "JQ tool: $JQ" >> ${LOG_FILE}
    echo "GIRDER credential: $GIRDER_CREDENTIALS" >> ${LOG_FILE}
    echo "GIRDER token: $GIRDER_TOKEN" >> ${LOG_FILE}
    export GIRDER_CREDENTIALS
    export GIRDER_TOKEN
}

# Login to girder using a token.
# Token should be created first to get
# GIRDER_CREDENTIALS_FILE and GIRDER_TOKEN
girder_login()
{
    GIRDER_REST_URL="${GIRDER_REPO_URL}/api/v1/user/authentication"
    echo "Request: ${GIRDER_REST_URL}" >> ${LOG_FILE}
    curl -s -f --show-error -X GET \
        -d "${GIRDER_CREDENTIALS}" \
        --header 'Accept: application/json' \
        --header "Girder-Token: ${GIRDER_TOKEN}" \
        "${GIRDER_REST_URL}" 2>> ${LOG_FILE}
}

# Logout from girder
girder_logout()
{
    GIRDER_REST_URL="${GIRDER_REPO_URL}/api/v1/user/authentication"
    echo "Request: ${GIRDER_REST_URL}" >> ${LOG_FILE}
    curl -s -f --show-error -X DELETE \
        -d "${GIRDER_CREDENTIALS}" \
        --header 'Accept: application/json' \
        --header "Girder-Token: ${GIRDER_TOKEN}" \
        "${GIRDER_REST_URL}" 2>> ${LOG_FILE}
}

# Get the girder item ID.
girder_simg_get_id()
{
    GIRDER_REST_URL="${GIRDER_REPO_URL}/api/v1/item?folderId=${GIRDER_FOLDER_ID}&name=${SIMG}&limit=50&sort=lowerName&sortdir=1"
    echo "Request: ${GIRDER_REST_URL}" >> ${LOG_FILE}
    GIRDER_ITEM_INFO=`curl -s -f --show-error -X GET --header 'Accept: application/json' \
        -d "${GIRDER_CREDENTIALS}" \
        --header 'Accept: application/json' \
        --header "Girder-Token: ${GIRDER_TOKEN}" \
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
        --header "Girder-Token: ${GIRDER_TOKEN}" \
        "${GIRDER_REST_URL}" \
        -o ${SIMG_DIR}/${SIMG} 2>> ${LOG_FILE}
}

debug_test()
{
    curl -s -d '' -f --show-error -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' 'https://girder.math.unistra.fr/api/v1/api_key/token?key=OmDiPO4eoAnvf9JkHHYk1LeFpSUuN6efCgqPIYbs&duration=1' &> ${LOG_FILE}
}

echo "MSO4SC Orchestrator bootstrap logs" > ${LOG_FILE}
date >> ${LOG_FILE}
printf '*%.0s' {1..60} >> ${LOG_FILE}
echo "" >> ${LOG_FILE}

if [ ! -f ${SIMG_DIR}/${SIMG} ]; then
    jq_parser
    echo "GIRDER create token" >> ${LOG_FILE}
#    debug_test
    girder_token_create
    echo "GIRDER login" >> ${LOG_FILE}
    girder_login
    echo "GIRDER get item id" >> ${LOG_FILE}
    girder_simg_get_id
    echo "GIRDER download item file" >> ${LOG_FILE}
    girder_simg_download
    echo "GIRDER logout" >> ${LOG_FILE}
    girder_logout
else
    echo "Bootstrap will use ${SIMG_DIR}/${SIMG} singularity image!" >> ${LOG_FILE}
fi


# First we create the feelpp model (json) and configure the openmodelica model (xml).
# MODEL parameters are stored in the array in the following order:
# JSON PARAM
#   @porosity_coeff@:  porosity [default = 0.015192]
#   @init_pressure@: initial blood pressure within the lamina cribrosa [default = 0.25]
#   @data_file@: the path to the results of OM [default =$cfgdir/data.csv ]
# XML PARAM
#   @final_time@: the final time of the simulation [default = 3, max allowed = 4]
#   @IOP_value@: the value of the intraocular pressure [default = 15 ]
#   @RLTp_value@: the value of retrolaminar tissue pressure [default = 7]
MODEL_JSON_IN=/usr/local/share/feelpp/testcases/level1/model.json.in 
MODEL_XML_IN=/usr/local/share/feelpp/testcases/level1/ominit.xml.in 
MODEL_JSON=${WORK_DIR}/data/model.json
MODULE_XML=${WORK_DIR}/data/ominit.xml
if [ ! -f ${MODEL_JSON_IN} ]; then echo "Error: ${MODEL_JSON_IN} missing in singularity image"; exit 1 fi
if [ ! -f ${MODEL_XML_IN} ]; then echo "Error: ${MODEL_XML_IN} missing in singularity image"; exit 1 fi
if [ -z ${MODULES} ]; then
    MODULES_LIST=`echo ${MODULES} | sed -e 's/,/ /g'`
    for i in ${MODULE_LIST}; do
        module load ${i}
    done
fi
singularity exec cp ${MODEL_JSON_IN} ${MODEL_JSON}
singularity exec cp ${MODEL_XML_IN} ${MODEL_XML}

sed -i s/@porosity_coeff@/${MODEL_PARAM_ARR[0]}/ ${MODEL_JSON}
sed -i s/@init_pressure@/${MODEL_PARAM_ARR[1]}/ ${MODEL_JSON}
sed -i s/@data_file@/${MODEL_PARAM_ARR[2]}/ ${MODEL_JSON}
sed -i s/@final_time@/${MODEL_PARAM_ARR[3]}/ ${MODEL_XML}
sed -i s/@IOP_value@/${MODEL_PARAM_ARR[4]}/ ${MODEL_XML}
sed -i s/@RLTp_value@/${MODEL_PARAM_ARR[5]}/ ${MODEL_XML}
