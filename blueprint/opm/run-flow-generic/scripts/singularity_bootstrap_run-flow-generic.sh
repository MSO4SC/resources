#!/bin/bash -l

WORKDIR=$1
REMOTE_URL=$2

cd $WORKDIR
wget $REMOTE_URL
ARCHIVE=$(basename $REMOTE_URL)
tar zxvf $ARCHIVE
DIRNAME=$(basename $ARCHIVE .tgz)
DECK=$(ls $DIRNAME/*.DATA)
cat << EOF > run_generated.param
deck_filename=$(readlink -m $WORKDIR)/$DECK
EOF

