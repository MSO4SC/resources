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

CLEANUP=""

# # upload result to data catalogue
# ckan...
# girder

# Remove image from the client ${SREGISTRY_STORAGE}
if [ $CLEANUP != "" ]; thrn
   sregistry rm ${IMAGE_URI}
fi
