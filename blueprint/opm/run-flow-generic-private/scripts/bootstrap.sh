#!/bin/bash -l

module load singularity/2.4.2

REMOTE_URL=$1
IMAGE_URI=$2
IMAGE_NAME=$3
PRIVATE=$4

# Pull image for simulator
singularity pull --name $IMAGE_NAME $IMAGE_URI

# Get data
if [ "$PRIVATE" == "true" ]; then
    singularity pull --name rclone-for-mso4sc.simg shub://sregistry.srv.cesga.es/mso4sc/rclone:latest
    singularity exec -B /mnt -H $HOME rclone-for-mso4sc.simg rclone copy $REMOTE_URL $CURRENT_WORKDIR/
else
    wget $REMOTE_URL
fi

# Unpack data
ARCHIVE=$(basename $REMOTE_URL)
tar zxvf $ARCHIVE

# Generate parameter file
DIRNAME=$(basename $ARCHIVE .tgz)
DECK=$(ls $DIRNAME/*.DATA)
cat << EOF > run_generated.param
ecl-deck-file-name=$(readlink -m $CURRENT_WORKDIR)/$DECK
EOF

