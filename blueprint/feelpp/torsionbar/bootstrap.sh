#!/bin/bash -l

# Singularity image retrieved from
# https://www.singularity-hub.org/collections/253

module load singularity/2.3.1

if [ ! -f $1/$2 ]; then
    cp $SINGULARITY_REPO/$2 $1
fi
