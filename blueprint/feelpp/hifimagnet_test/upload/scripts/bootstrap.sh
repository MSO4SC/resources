#!/bin/bash -l

# set -euo pipefail
# set -x

# Custom logs
LOG_FILE=$0.log

echo "bootstrap" >> ${LOG_FILE}
echo "parameters: $@" >> ${LOG_FILE}

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
# $9 - { get_input: mso4sc_dataset_input_url }

# params for output


export SREGISTRY_STORAGE=$1 >> ${LOG_FILE}

IMAGE_NAME=$2
IMAGE_URI=$3
IMAGE_CLEANUP=$4

export SREGISTRY_CLIENT=$5 >> ${LOG_FILE}
export SREGISTRY_CLIENT_SECRETS=$6 >> ${LOG_FILE}

SREGISTRY_URL=$7
SREGISTRY_IMAGE=$8

# Ckan:
REMOTE_URL=$9

echo "${SREGISTRY_URL}" >> ${LOG_FILE}
echo "${SREGISTRY_IMAGE}" >> ${LOG_FILE}

# module should be optional:
isModule=$(compgen -A function | grep  module)
if [ "$isModule" != "" ]; then
    module load singularity >> ${LOG_FILE}
fi

# Singularity image retrieved from
# https://www.singularity-hub.org/collections/253

echo "CURRENT_WORKIR=$CURRENT_WORKDIR" >> ${LOG_FILE}
echo "IMAGE_NAME=$IMAGE_NAME" >> ${LOG_FILE}
echo "IMAGE_URI=$IMAGE_URI" >> ${LOG_FILE}

echo "SREGISTRY_STORAGE=${SREGISTRY_STORAGE}" >> ${LOG_FILE}
echo "SREGISTRY_URL=${SREGISTRY_URL}" >> ${LOG_FILE}
echo "SREGISTRY_IMAGE=${SREGISTRY_IMAGE}" >> ${LOG_FILE}

# Check if secrets exist
if [ ! -f ${SREGISTRY_CLIENT_SECRETS} ]; then
    echo "No SRegistry secrets found: ${SREGISTRY_CLIENT_SECRETS}" >> ${LOG_FILE}
    echo "You have to upload such file first on HPC resources" >> ${LOG_FILE}
    exit 1
fi

if [ ! -d ${SREGISTRY_STORAGE} ]; then
    mkdir -p ${SREGISTRY_STORAGE}
fi
				      
# Get Singularity image if not already installed
if [ ! -f ${SREGISTRY_STORAGE}/$IMAGE_NAME ]; then
   isSregistry=$(which sregistry)
   if  [ "$isSregistry" != "" ] && [ ${SREGISTRY_URL} != "" ] && [ ${SREGISTRY_IMAGE} != "" ]; then
       echo "Get ${IMAGE_NAME} using sregistry-cli" >> ${LOG_FILE}
       # On Lnmci
       sregistry get ${IMAGE_URI} >> ${LOG_FILE}
       sregistry rename ${IMAGE_URI} ${IMAGE_NAME} >> ${LOG_FILE}
       
   else
       echo "Get $IMAGE_URI ($IMAGE_NAME) using intermediate shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE}" >> ${LOG_FILE}
       # On Cesga:
       singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} pull ${IMAGE_URI} 2>&1 >> ${LOG_FILE}
       status=$?
       echo "singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} pull ${IMAGE_URI} (status=$status)" >> ${LOG_FILE}
       if [ $status != "0" ]; then
	   echo "singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} pull ${IMAGE_URI}: FAILS"
	   exit 1
       fi
       echo "Rename $IMAGE_URI to $IMAGE_NAME" >> ${LOG_FILE}
       singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} rename ${IMAGE_URI} ${IMAGE_NAME} 2>&1 >> ${LOG_FILE}
       status=$?
       echo "singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} rename ${IMAGE_URI} ${IMAGE_NAME} (status=$status)" >> ${LOG_FILE}
       if [ $status != "0" ]; then
	   echo "singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} rename ${IMAGE_URI}: FAILS"
	   exit 1
       fi
   fi
fi

# Get data from ckan
if [ "x$REMOTE_URL" != "x" ] && [ "$REMOTE_URL" != "None" ]; then
    wget $REMOTE_URL >> ${LOG_FILE}
    ARCHIVE=$(basename $REMOTE_URL) >> ${LOG_FILE}
    tar zxvf $ARCHIVE >> ${LOG_FILE}
fi

# ctx logger info "Some logging"
# # read access
# ctx node properties tasks
