#!/bin/bash -l

module load singularity/2.4.2

REMOTE_URL=$1
IMAGE_URI=$2
IMAGE_NAME=$3

# cd $CURRENT_WORKDIR ## not needed, already started there
singularity pull --name $IMAGE_NAME $IMAGE_URI
wget $REMOTE_URL
ARCHIVE=$(basename $REMOTE_URL)
tar zxvf $ARCHIVE
DIRNAME=$(basename $ARCHIVE .tgz)
DECK=$(ls $DIRNAME/*.DATA)
cat << EOF > run_generated.param
ecl-deck-file-name=$(readlink -m $CURRENT_WORKDIR)/$DECK
EOF

