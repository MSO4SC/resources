#!/bin/bash -l

# Singularity image retrieved from
# https://www.singularity-hub.org/collections/253

module load singularity/2.4.2

WORKDIR=$1
REMOTE_URL=$2
IMAGE_URI=$3
IMAGE_NAME=$4
#CFGFILE=$5

# Get singularity images
cd $WORKDIR/singularity_images
if [ ! -f $IMAGE_NAME ]; then
    singularity pull --name $IMAGE_NAME $IMAGE_URI
fi

cd $WORKDIR
# # Fetch data if REMOTE_URL is declared
# if  [ "$REMOTE_URL" != "" ]; then
#     wget $REMOTE_URL
#     ARCHIVE=$(basename $REMOTE_URL)
#     tar zxvf $ARCHIVE

#     # should check if CFGFILE exist
# fi 
