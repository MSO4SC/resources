#!/bin/bash -l

# Only remove singularity image if file was copy from the repo.
if [ -f ${SINGULARITY_REPO}/$2 ]
    if [ -f $1/$2 ]; then
        rm $1/$2
    fi
fi
