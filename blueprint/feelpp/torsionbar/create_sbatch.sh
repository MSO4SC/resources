#!/bin/bash -l

# Singularity image retrieved from
# https://www.singularity-hub.org/collections/253

module load singularity/2.3.1

SLURMDIR=$1
IMAGENAME=$2
IMAGEDEST=$3

IMAGENAME23=$(basename ${IMAGENAME}).2.3.1

cd ${IMAGEDEST}
if [ -f "${IMAGENAME}" ]; then
  singularity pull -name "${IMAGENAME}" shub://feelpp/singularity:feelpp-toolboxes-latest
fi
if [ -f "${IMAGENAME23}" ]; then
  singularity build --writable ${IMAGENAME23} ${IMAGENAME}
fi

sed -i s/FEELPP_SINGULARITY_IMAGE=.*/FEELPP_SINGULARITY_IMAGE=$3/ $2
