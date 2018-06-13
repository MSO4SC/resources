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
# $10 - {concat [{get_input: hpc_basedir}, '/feel']}

export SREGISTRY_STORAGE=$1 >> ${LOG_FILE}

IMAGE_NAME=$2
IMAGE_URI=$3
IMAGE_CLEANUP=$4

export SREGISTRY_CLIENT=$5 >> ${LOG_FILE}
export SREGISTRY_CLIENT_SECRETS=$6 >> ${LOG_FILE}

SREGISTRY_URL=$7
SREGISTRY_IMAGE=$8

# Ckan:
if [ $nargs -ge 9 ]; then
    REMOTE_URL=$9
fi

# Feel output result directory
if [ $nargs -ge 10 ]; then
    FEELPP_OUTPUT_DIR=$10/feel
fi

# # upload result to data catalogue
# ckan...
# girder

# module should be optional:
isModule=$(compgen -A function | grep  module)
echo "isModule=${isModule}" >> ${LOG_FILE}
if [ "$isModule" != "" ]; then
    module load singularity >> ${LOG_FILE}
fi


# Remove image from the client ${SREGISTRY_STORAGE}
echo "IMAGE_CLEANUP=${IMAGE_CLEANUP}" >> ${LOG_FILE}
if [ $IMAGE_CLEANUP = "true"  ]; then
   isSregistry=$(which sregistry 2>&1 > /dev/null)
   echo "isSregistry=$isSregistry"
   if  [ "$isSregistry" != "" ] && [ ${SREGISTRY_URL} != "" ] && [ ${SREGISTRY_IMAGE} != "" ]; then
       sregistry rm ${IMAGE_URI} >> ${LOG_FILE}
   else
       singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} rmi ${IMAGE_URI} >> ${LOG_FILE}
   fi
fi


