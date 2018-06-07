#!/bin/bash -l

module load singularity/2.4.2

WORKDIR=$1
URI=$2
FILE=$3

mkdir -p $WORKDIR
if [ ! -f $WORKDIR/$FILE ]; then
    cd $WORKDIR
    singularity pull --name $FILE $URI &> bootstrap.log
fi
