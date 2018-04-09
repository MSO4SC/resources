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
ls $DIRNAME/*/*.DATA > decks
IFS=$'\n'
i=0
for deck in $(cat decks)
do
    cat << EOF > run_generated_$i.param
deck_filename=$(readlink -m $CURRENT_WORKDIR)/$deck
output_dir=$(readlink -m $CURRENT_WORKDIR)/simoutput_$i
EOF
    i=$[i+1]
done

cat << EOF > run_flow.sh
flow run_generated_\$SCALE_INDEX.param
EOF
