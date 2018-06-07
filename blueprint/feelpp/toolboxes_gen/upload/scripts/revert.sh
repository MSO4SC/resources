#!/bin/bash -l

WORKDIR=$1
URI=$2
FILENAME=$3

rm -f $WORKDIR/$FILENAME &> revert.log
