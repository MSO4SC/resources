#!/bin/bash -l

WORKDIR=$1
REMOTE_URL=$2

cd $WORKDIR
rm $(basename $REMOTE_URL)
EOF
