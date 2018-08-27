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

# Generate parameter files
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

# Generate run script
cat << EOF > run_flow.sh
flow run_generated_\$SLURM_ARRAY_TASK_ID.param
EOF
chmod a+x run_flow.sh
