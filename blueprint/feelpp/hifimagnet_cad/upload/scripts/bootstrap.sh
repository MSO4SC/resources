#!/bin/bash -l

# set -euo pipefail
# set -x

# Custom logs
LOG_FILE=$0.log

echo "bootstrap" >> "${LOG_FILE}"
echo "parameters: $*" >> "${LOG_FILE}"

nargs=$#
echo "nargs: $nargs" >> "${LOG_FILE}"
echo "last arg: ${!nargs}" >> "${LOG_FILE}"

# params for singularity images:
# $1 - { get_input: sregistry_storage }
# $2 - { get_input: singularity_image_filename - aka collection/}
# $3 - { get_input: singularity_image_uri }
# $4 - { get_input: singularity_image_cleanup }
# $5 - { get_input: sregistry_client }
# $6 - { get_input: sregistry_secrets } 
# $7 - { get_input: sregistry_url }
# $8 - { get_input: sregistry_image } 

# params fo input data
# $9 - { get_input: mso4sc_dataset_model }
# $10 - { get_input: mso4sc_datacatalogue_key }

# input file
# $11 - {get_input: cadcfg}

export SREGISTRY_STORAGE=$1 >> "${LOG_FILE}"

IMAGE_NAME=$2
IMAGE_URI=$3
# IMAGE_CLEANUP=$4

export SREGISTRY_CLIENT=$5 >> "${LOG_FILE}"
export SREGISTRY_CLIENT_SECRETS=$6 >> "${LOG_FILE}"

SREGISTRY_URL=$7
SREGISTRY_IMAGE=$8

# Ckan:
DATASET=""
CATALOGUE_TOKEN=""
DATA=""

if [ "$nargs" -ge 9 ]; then
    DATASET=${9}
fi
if [ "$nargs" -ge 10 ]; then
    CATALOGUE_TOKEN=${10}
fi
if [ "$nargs" -ge 11 ]; then
    DATA=${11}
fi


echo "${SREGISTRY_URL}" >> "${LOG_FILE}"
echo "${SREGISTRY_IMAGE}" >> "${LOG_FILE}"

# module should be optional:
isModule=$(compgen -A function | grep  module)
if [ "$isModule" != "" ]; then
    module load singularity >> "${LOG_FILE}"
fi

# Singularity image retrieved from
# https://www.singularity-hub.org/collections/253

echo "CURRENT_WORKIR=$CURRENT_WORKDIR" >> "${LOG_FILE}"
echo "IMAGE_NAME=$IMAGE_NAME" >> "${LOG_FILE}"
echo "IMAGE_URI=$IMAGE_URI" >> "${LOG_FILE}"

echo "SREGISTRY_STORAGE=${SREGISTRY_STORAGE}" >> "${LOG_FILE}"
echo "SREGISTRY_URL=${SREGISTRY_URL}" >> "${LOG_FILE}"
echo "SREGISTRY_IMAGE=${SREGISTRY_IMAGE}" >> "${LOG_FILE}"

# Check if secrets exist
if [ ! -f "${SREGISTRY_CLIENT_SECRETS}" ]; then
    echo "No SRegistry secrets found: ${SREGISTRY_CLIENT_SECRETS}" >> "${LOG_FILE}"
    echo "You have to upload such file first on HPC resources" >> "${LOG_FILE}"
    exit 1
fi

if [ ! -d "${SREGISTRY_STORAGE}" ]; then
    mkdir -p "${SREGISTRY_STORAGE}"
fi
				      
# Get Singularity image if not already installed
if [ ! -f "${SREGISTRY_STORAGE}/$IMAGE_NAME" ]; then
   isSregistry=$(which sregistry)
   if  [ "$isSregistry" != "" ] && [ "${SREGISTRY_URL}" != "" ] && [ "${SREGISTRY_IMAGE}" != "" ]; then
       echo "Get ${IMAGE_NAME} using sregistry-cli" >> "${LOG_FILE}"
       # On Lnmci
       sregistry get "${IMAGE_URI}" >> "${LOG_FILE}"
       status=$?
       if [ $status != "0" ]; then
	   echo "sregistry get ${IMAGE_URI}: FAILS" >> "${LOG_FILE}"
	   exit 1
       fi
       sregistry rename "${IMAGE_URI}" "${IMAGE_NAME}" >> "${LOG_FILE}"
       status=$?
       if [ $status != "0" ]; then
	   echo "sregistry rename ${IMAGE_URI} ${IMAGE_NAME}: FAILS" >> "${LOG_FILE}"
	   exit 1
       fi
       
   else
       echo "Get $IMAGE_URI ($IMAGE_NAME) using intermediate shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE}" >> "${LOG_FILE}"
       # On Cesga:
       singularity run -B /mnt shub://"${SREGISTRY_URL}"/"${SREGISTRY_IMAGE}" pull "${IMAGE_URI}" >> "${LOG_FILE}" 2>&1
       status=$?
       echo "singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} pull ${IMAGE_URI} (status=$status)" >> "${LOG_FILE}"
       if [ $status != "0" ]; then
	   echo "singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} pull ${IMAGE_URI}: FAILS" >> "${LOG_FILE}"
	   exit 1
       fi
       echo "Rename $IMAGE_URI to $IMAGE_NAME" >> "${LOG_FILE}"
       singularity run -B /mnt shub://"${SREGISTRY_URL}"/"${SREGISTRY_IMAGE}" rename "${IMAGE_URI}" "${IMAGE_NAME}" >> "${LOG_FILE}" 2>&1
       status=$?
       echo "singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} rename ${IMAGE_URI} ${IMAGE_NAME} (status=$status)" >> "${LOG_FILE}"
       if [ $status != "0" ]; then
	   echo "singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} rename ${IMAGE_URI}: FAILS" >> "${LOG_FILE}"
	   exit 1
       fi
   fi
fi

# Get data from ckan
echo "DATASET=${DATASET}" >> "${LOG_FILE}"
echo "CATALOGUE_TOKEN=${CATALOGUE_TOKEN}" >> "${LOG_FILE}"
echo "DATA=${DATA}" >> "${LOG_FILE}"

ARCHIVE=${DATASET}
ARCHIVE=$(echo $ARCHIVE | perl -pi -e "s|.*/||")
isstatus=$?
if [ "$isstatus" == 1 ]; then
    exit 1
fi    
echo "ARCHIVE=$ARCHIVE"  >> "${LOG_FILE}"

OPTIONS=""
if [ "$CATALOGUE_TOKEN" ]; then
    OPTIONS="-H \"Authorization: ${CATALOGUE_TOKEN}\""
fi

if [ "x$DATASET" != "x" ] && [ "$DATASET" != "None" ]; then
    echo "curl $OPTIONS $DATASET -o $ARCHIVE" >> "${LOG_FILE}"
    # curl $OPTIONS $DATASET -o $ARCHIVE : Not working why???
    if [ "$CATALOGUE_TOKEN" ]; then
	curl -H "Authorization: ${CATALOGUE_TOKEN}" $DATASET -o $ARCHIVE
	isDownloaded=$?
    else
	curl $DATASET -o $ARCHIVE
	isDownloaded=$?
    fi
    # harcoded working:
    # curl -H "Authorization: 5c1fcb82-9987-47df-9f7f-f02363b18419" http://193.144.35.207:80/dataset/1fc75820-496d-428c-83ce-446c783fa4a2/resource/0c541e65-6f6d-4f52-9682-a072f44c8fa8/download/insert-h1h4.tgz -o insert-h1h4.tgz
    # isDownloaded=$?
    if [ "$isDowloaded" == 1 ]; then
	echo "curl $OPTIONS $DATASET -o $ARCHIVE : FAILS" >> "${LOG_FILE}"
        exit 1
    fi
    
    TYPE=$(file $ARCHIVE | perl -pi -e "s|$ARCHIVE: ||")
    echo "type($ARCHIVE)=$TYPE"  >> "${LOG_FILE}"
    
    tar zxvf "$ARCHIVE" >> "${LOG_FILE}"

    # check if input file is present
    if [ ! -f "$DATA" ]; then
	echo "$DATA: no such file in dataset $DATASET"
	exit 1
    fi
fi

# ctx logger info "Some logging"
# # read access
# ctx node properties tasks
