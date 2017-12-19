#!/bin/bash -l

WORKDIR=$1
REMOTE_URL=$2

cd $WORKDIR
ARCHIVE=$(basename $REMOTE_URL)
rm $ARCHIVE
DIRNAME=$(basename $ARCHIVE .tgz)
rm -r $DIRNAME
rm run_generated.param
