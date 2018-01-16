#!/bin/bash -l

module load singularity/2.4.2

WORKDIR=$1
REMOTE_URL=$2
IMAGE_URI=$3
IMAGE_NAME=$4
#CFGFILE=$5

cd $WORKDIR/singularity_images
# do not remove singularity image: rm $IMAGE_NAME

cd $WORKDIR
# if  [ "$REMOTE_URL" != "" ]; then
#     ARCHIVE=$(basename $REMOTE_URL)
#     rm $ARCHIVE
# fi
