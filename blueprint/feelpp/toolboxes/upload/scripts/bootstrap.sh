#!/bin/bash -l

if [ ! -f $1/$2 ]; then
    echo "ERROR: The singularity file is missing" &> bootstrap.log 
    exit 1
fi
