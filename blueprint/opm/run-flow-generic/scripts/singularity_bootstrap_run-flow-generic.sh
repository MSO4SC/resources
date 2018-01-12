#!/bin/bash -l

module load singularity/2.4.2

WORKDIR=$1
REMOTE_URL=$2
IMAGE_URI=$3
IMAGE_NAME=$4

cd $WORKDIR
singularity pull --name $IMAGE_NAME $IMAGE_URI
wget $REMOTE_URL
ARCHIVE=$(basename $REMOTE_URL)
tar zxvf $ARCHIVE
DIRNAME=$(basename $ARCHIVE .tgz)
DECK=$(ls $DIRNAME/*.DATA)
cat << EOF > run_generated.param
deck_filename=$(readlink -m $WORKDIR)/$DECK
EOF

