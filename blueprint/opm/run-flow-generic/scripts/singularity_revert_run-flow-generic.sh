#!/bin/bash -l

WORKDIR=$1
REMOTE_URL=$2
IMAGE_URI=$3
IMAGE_NAME=$4

cd $WORKDIR
rm $IMAGE_NAME
ARCHIVE=$(basename $REMOTE_URL)
rm $ARCHIVE
DIRNAME=$(basename $ARCHIVE .tgz)
rm -r $DIRNAME
rm run_generated.param
