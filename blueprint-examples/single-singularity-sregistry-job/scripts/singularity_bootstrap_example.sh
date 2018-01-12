#!/bin/bash -l

module load singularity/2.4.2

URI=$1
FILENAME=$2

singularity pull --name $FILENAME $URI &> bootstrap.log
