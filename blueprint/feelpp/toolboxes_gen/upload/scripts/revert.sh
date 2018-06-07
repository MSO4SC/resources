#!/bin/bash -l

WORKDIR=$1
URI=$2
FILENAME=$3

if [ -f $WORKDIR/$FILE ]; then
    rm -f $WORKDIR/$FILENAME &> revert.log
fi
