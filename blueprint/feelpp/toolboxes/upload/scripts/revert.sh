#!/bin/bash -l
SIMG_DIR=$1
SIMG=$2
NO_ERASE=$6

# Only remove singularity image if file was copy from the repo.
if [[ "${NO_ERASE}" == "False" ]] || [[ "${NO_ERASE}" == "false" ]]; then
    if [ -f ${SIMG_DIR}/${SIMG} ]; then
        echo "Deleting singularity file ${SIMG_DIR}/${SIMG} !"
        rm ${SIMG_DIR}/${SIMG}
    fi
fi
