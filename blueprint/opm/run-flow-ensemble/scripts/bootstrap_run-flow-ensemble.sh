#!/bin/bash -l

module load singularity/2.4.2

REMOTE_URL=$1
IMAGE_URI=$2
IMAGE_NAME=$3

# cd $CURRENT_WORKDIR ## not needed, already started there
singularity pull --name $IMAGE_NAME $IMAGE_URI
wget $REMOTE_URL

# Unpack data
ARCHIVE=$(basename $REMOTE_URL)
tar zxvf $ARCHIVE

# Generate parameter files
DIRNAME=$(basename $ARCHIVE .tgz)
ls $DIRNAME/*/*.DATA > decks
IFS=$'\n'
i=0
for deck in $(cat decks)
do
    cat << EOF > run_generated_$i.param
ecl-deck-file-name=$(readlink -m $CURRENT_WORKDIR)/$deck
output-dir=$(readlink -m $CURRENT_WORKDIR)/simoutput_$i
EOF
    i=$[i+1]
done

# Generate run script
cat << EOF > run_flow.sh
flow --parameter-file=run_generated_\$SLURM_ARRAY_TASK_ID.param
EOF
chmod a+x run_flow.sh
