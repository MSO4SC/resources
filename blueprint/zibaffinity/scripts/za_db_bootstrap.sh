#!/bin/bash -l

module load singularity/2.3.1

if [ ! -f $2/$3 ]; then
    cp $1/$3 $2/
    rm $2/sim_dir/targets.txt
fi

#if [ ! -f $1/$2 ]; then
#    cp $SINGULARITY_REPO/$2 $1
#fi

module unload singularity/2.3.1

