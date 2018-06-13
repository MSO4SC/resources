#!/bin/bash -l

# set -euo pipefail
# set -x

# Custom logs
LOG_FILE=$0.log

echo "revert" >> ${LOG_FILE}
echo "parameters: $@" >> ${LOG_FILE}

nargs=$#
echo "nargs: $nargs" >> ${LOG_FILE}
echo "last arg: ${!nargs}" >> ${LOG_FILE}

# params for singularity images:
# $1   - { get_input: sregistry_storage }
# $2   - { get_input: singularity_image_filename - aka collection/}
# $3   - { get_input: singularity_image_uri }
# $4   - { get_input: singularity_image_cleanup }
# $5   - { get_input: sregistry_client }
# $6   - { get_input: sregistry_secrets } 
# $7   - { get_input: sregistry_url }
# $8   - { get_input: sregistry_image } 

# params for output
# $9 - {get_input: hpc_feelpp}

# params fo input data
# $10 - { get_input: mso4sc_dataset_input_url }

export SREGISTRY_STORAGE=$1

IMAGE_NAME=$2
IMAGE_URI=$3
IMAGE_CLEANUP=$4

export SREGISTRY_CLIENT=$5
export SREGISTRY_CLIENT_SECRETS=$6

echo "SREGISTRY_STORAGE=$SREGISTRY_STORAGE" >> ${LOG_FILE} 2>&1
echo "SREGISTRY_CLIENT=$SREGISTRY_CLIENT" >> ${LOG_FILE} 2>&1
echo "SREGISTRY_CLIENT_SECRETS=$SREGISTRY_CLIENT_SECRETS=" >> ${LOG_FILE} 2>&1

SREGISTRY_URL=${7}
SREGISTRY_IMAGE=${8}

# Feel output result directory
if [ $nargs -ge 9 ]; then
    FEELPP_OUTPUT_DIR=${9}
    echo "FEELPP_OUTPUT_DIR=" ${FEELPP_OUTPUT_DIR} >> ${LOG_FILE} 2>&1
fi

# Ckan:
if [ $nargs -ge 10 ]; then
    REMOTE_URL=${10}
fi

# # upload result to data catalogue
# ckan...
# girder

# module should be optional:
isModule=$(compgen -A function | grep  module)
echo "isModule=${isModule}" >> ${LOG_FILE} 2>&1
if [ "$isModule" != "" ]; then
    module load singularity >> ${LOG_FILE} 2>&1
fi


# Remove image from the client ${SREGISTRY_STORAGE}
echo "IMAGE_CLEANUP=${IMAGE_CLEANUP}" >> ${LOG_FILE} 2>&1
if [ $IMAGE_CLEANUP = "true"  ]; then
   isSregistry=$(which sregistry 2>&1 > /dev/null)
   echo "isSregistry=$isSregistry"
   if  [ "$isSregistry" != "" ] && [ ${SREGISTRY_URL} != "" ] && [ ${SREGISTRY_IMAGE} != "" ]; then
       sregistry rmi ${IMAGE_URI} >> ${LOG_FILE} 2>&1
   else
       singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} rmi ${IMAGE_URI} >> ${LOG_FILE} 2>&1
   fi
fi
