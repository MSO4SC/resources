#!/bin/bash -l


if [ ! -f $2/$3 ]; then

    module purge
    module load $4
    
    cd $2
    singularity pull --name $3 $1

    #cp $1/$3 $2/
    #cp $SINGULARITY_REPO/$3 $2/
    
    module unload $4
fi


