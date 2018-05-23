#!/bin/bash -l

echo "bootstrap"
echo "parameters: $@"

# params for singularity images:
# $1 - { get_input: sregistry_storage }
# $2 - { get_input: singularity_image_filename - aka collection/}
# $3 - { get_input: singularity_image_uri }
# $4 - { get_input: sregistry_client }
# $5 - { get_input: sregistry_secrets } 
# $6 - { get_input: sregistry_url }
# $7 - { get_input: sregistry_image } 

# params fo input data
# $8 - { get_input: mso4sc_dataset_input_url }

# params for output

export SREGISTRY_STORAGE=$1

IMAGE_NAME=$2
IMAGE_URI=$3

export SREGISTRY_CLIENT=$4
export SREGISTRY_CLIENT_SECRETS=$5

SREGISTRY_URL=$6
SREGISTRY_IMAGE=$7

# Ckan:
REMOTE_URL=$8

echo "${SREGISTRY_URL}"
echo "${SREGISTRY_IMAGE}"

# module should be optional:
isModule=$(which module)
if [ "$isModule" != "" ]; then
    module load singularity/2.4.2
fi

# Singularity image retrieved from
# https://www.singularity-hub.org/collections/253

echo "CURRENT_WORKIR=$CURRENT_WORKDIR"
echo "IMAGE_NAME=$IMAGE_NAME"
echo "IMAGE_URI=$IMAGE_URI"

echo "SREGISTRY_STORAGE=${SREGISTRY_STORAGE}"
echo "SREGISTRY_URL=${SREGISTRY_URL}"
echo "SREGISTRY_IMAGE=${SREGISTRY_IMAGE}"

# Check if secrets exist
if [ ! -f ${SREGISTRY_CLIENT_SECRETS} ]; then
    echo "No SRegistry secrets found: ${SREGISTRY_CLIENT_SECRETS}"
    echo "You have to upload such file first on HPC resources"
    exit 1
fi
				      
# Get Singularity image if not already installed
if [ ! -f ${SREGISTRY_STORAGE}/$IMAGE_NAME ]; then
   isSregistry=$(which sregistry)
   if [ ${SREGISTRY_URL} != "" &&  ${SREGISTRY_IMAGE} != "" && "$isSregistry" != "" ]; then
       echo "Get $IMAGE_NAME using sregistry-cli"
       # On Lnmci
       sregistry get $IMAGE_URI
       sregistry rename $IMAGE_URI $IMAGE_NAME
       
   else
       echo "Get $IMAGE_NAME using intermediate shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE}"
       # On Cesga:
       singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} pull $IMAGE_URI
       singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} rename $IMAGE_URI $IMAGE_NAME 
    fi
fi

# Get data from ckan
if [ "x$REMOTE_URL" != "x" ]; then
    wget $REMOTE_URL
    ARCHIVE=$(basename $REMOTE_URL)
    tar zxvf $ARCHIVE
fi

# ctx logger info "Some logging"
# # read access
# ctx node properties tasks
