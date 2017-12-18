#!/bin/bash -l

WORKDIR=$1
REMOTE_URL=$2

cd $WORKDIR
wget $REMOTE_URL
cat << EOF > run_generated.param
deck_filename=$(readlink -m $WORKDIR)/$(basename $REMOTE_URL)
EOF

