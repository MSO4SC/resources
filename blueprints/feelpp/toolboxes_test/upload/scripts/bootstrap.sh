#!/bin/bash -l
SIMG_DIR=$1
SIMG=$2
GIRDER_FOLDER_ID=$3

if [ -z ${SIMG_DIR} ]; then echo "Error: $0: args : no directory passed!"; exit 1; fi;
if [ -z ${SIMG} ]; then echo "Error: $0: args: no singularity image passed!"; exit 1; fi;
if [ -z ${GIRDER_FOLDER_ID} ]; then echo "Error: $0: args: no girder folder ID passed!"; exit 1; fi;

# Download and use jq tool to parse JSON HTTP request response.
JQ=`which jq`

if [ -z $JQ ]; then
    curl -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -o $1/jq
    chmod 755 $1/jq
    JQ=$1/jq
fi

# Get the girder item ID.
girder_simg_get_id()
{
    curl -s -d '' -X GET --header 'Accept: application/json' \
        "https://girder.math.unistra.fr/api/v1/item?folderId=${GIRDER_FOLDER_ID}&name=${SIMG}&limit=50&sort=lowerName&sortdir=1" \
        | ${JQ} -rc '.[]._id'
}

# Get the girder file associated to the girder item ID.
girder_simg_download()
{
    curl --progress-bar -d '' -X GET --header 'Accept: application/json' \
        "https://girder.math.unistra.fr/api/v1/item/${GIRDER_ITEM_ID}/download?contentDisposition=attachment" \
        -o ${SIMG_DIR}/${SIMG}
}

if [ ! -f ${SIMG_DIR}/${SIMG} ]; then
    GIRDER_ITEM_ID=`girder_simg_get_id`
    if [ ! -z ${GIRDER_ITEM_ID} ]; then
        echo "Downloading Feel++ toolbox singularity images..."
        `girder_simg_download`
    else
        echo "File $SIMG not found on girder!"
    fi
else
    echo "Bootstrap will use ${SIMG_DIR}/${SIMG} singularity image!"
fi
