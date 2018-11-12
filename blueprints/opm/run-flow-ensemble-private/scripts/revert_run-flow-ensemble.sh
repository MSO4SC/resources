#!/bin/bash -l

REMOTE_URL=$1
IMAGE_URI=$2
IMAGE_NAME=$3
PRIVATE=$4

# cd $CURRENT_WORKDIR ## not needed, already started there

if [ "$PRIVATE" == "true" ]; then
    rm rclone-for-mso4sc.simg
fi


rm $IMAGE_NAME
ARCHIVE=$(basename $REMOTE_URL)
rm $ARCHIVE
DIRNAME=$(basename $ARCHIVE .tgz)
rm -r $DIRNAME
rm decks
rm run_generated*.param
rm run_flow.sh
