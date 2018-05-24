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

# # upload result to data catalogue
# ckan...
# girder

# module should be optional:
isModule=$(compgen -A function | grep  module)
if [ "$isModule" != "" ]; then
    module load singularity >> ${LOG_FILE}
fi


# Remove image from the client ${SREGISTRY_STORAGE}
if [ $IMAGE_CLEANUP  ]; then
   isSregistry=$(which sregistry 2>&1 > /dev/null)
   if  [ "$isSregistry" != "" ] && [ ${SREGISTRY_URL} != "" ] && [ ${SREGISTRY_IMAGE} != "" ]; then
       sregistry rm ${IMAGE_URI} >> ${LOG_FILE}
   else
       singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} rmi ${IMAGE_URI} >> ${LOG_FILE}
   fi
fi
