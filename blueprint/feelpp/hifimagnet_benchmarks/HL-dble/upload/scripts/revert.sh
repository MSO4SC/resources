#!/bin/bash -l

# Only remove singularity image if file was copy from the repo.
if [ -f ${SINGULARITY_REPO}/$2 ]
    if [ -f $1/$2 ]; then
        echo "Deleting singularity file $1/$2 !"
        rm $1/$2
    fi
fi

# Get Simulation directory name
   
WORKDIR=$3
cd $WORKDIR

# REMOTE_URL=$4
# ARCHIVE=$(basename $REMOTE_URL)
# rm $ARCHIVE
# DIRNAME=$(basename $ARCHIVE .tgz)
# rm -r $DIRNAME
# rm run_generated.param
