#!/bin/bash -l

# set -euo pipefail
# set -x

# Custom logs
LOG_FILE=$0.log

echo "bootstrap" >> ${LOG_FILE}
echo "parameters: $@" >> ${LOG_FILE}

nargs=$#
echo "nargs: $nargs" >> ${LOG_FILE}
echo "last arg: ${!nargs}" >> ${LOG_FILE}

# params for singularity images:
# $1   - { get_input: sregistry_storage }
# $2   - { get_input: singularity_image_filename - aka collection/}
# $3   - { get_input: singularity_image_uri }
# $4   - { get_input: singularity_image_cleanup }
# $5   - { get_input: sregistry_client }
# $6   - { get_input: sregistry_secrets } 
# $7  - { get_input: sregistry_url }
# $8  - { get_input: sregistry_image } 

# params for output
# $9 - {get_input: hpc_feelpp}

# params fo input data
# $10 - { get_input: mso4sc_dataset_input_url }


# NODES=$1
# TASKS=$2
# TASK_PER_NODE=$3

# # Check if $TASKS = $NODES*${TASK_PER_NODES
# RESULT=$(echo "$(($NODES * ${TASK_PER_NODES}))" )
# if [ $TASKS -ne $RESULT ]; then
#    echo "incoherent number of task: nodes=$NODES, task_per_nodes=${TASK_PER_NODES} but tasks=$TASKS != $RESULT)" >> ${LOG_FILE} 2>&1
#    exit 1    
# fi

export SREGISTRY_STORAGE=$1 >> ${LOG_FILE}

IMAGE_NAME=$2
IMAGE_URI=$3
IMAGE_CLEANUP=$4

export SREGISTRY_CLIENT=$5
export SREGISTRY_CLIENT_SECRETS=$6

echo "SREGISTRY_STORAGE=$SREGISTRY_STORAGE" >> ${LOG_FILE} 2>&1
echo "SREGISTRY_CLIENT=$SREGISTRY_CLIENT" >> ${LOG_FILE} 2>&1
echo "SREGISTRY_CLIENT_SECRETS=$SREGISTRY_CLIENT_SECRETS=" >> ${LOG_FILE} 2>&1

SREGISTRY_URL=${7}
SREGISTRY_IMAGE=${8}

# # Feel output result directory
if [ $nargs -ge 9 ]; then
    FEELPP_OUTPUT_DIR=${9}
    echo "FEELPP_OUTPUT_DIR=${FEELPP_OUTPUT_DIR}" >> ${LOG_FILE} 2>&1
    if [ ! -d ${FEELPP_OUTPUT_DIR} ]; then
	mkdir -p ${FEELPP_OUTPUT_DIR} >> ${LOG_FILE} >> ${LOG_FILE} 2>&1
    fi
fi

# Ckan:
if [ $nargs -ge 10 ]; then
    REMOTE_URL=${10}
fi

# module should be optional:
isModule=$(compgen -A function | grep  module)
if [ "$isModule" != "" ]; then
    module load singularity >> ${LOG_FILE} 2>&1
fi

# Singularity image retrieved from
# https://www.singularity-hub.org/collections/253

echo "CURRENT_WORKIR=$CURRENT_WORKDIR" >> ${LOG_FILE} 2>&1
echo "IMAGE_NAME=$IMAGE_NAME" >> ${LOG_FILE} 2>&1
echo "IMAGE_URI=$IMAGE_URI" >> ${LOG_FILE} 2>&1

echo "SREGISTRY_STORAGE=${SREGISTRY_STORAGE}" >> ${LOG_FILE} 2>&1
echo "SREGISTRY_URL=${SREGISTRY_URL}" >> ${LOG_FILE} 2>&1
echo "SREGISTRY_IMAGE=${SREGISTRY_IMAGE}" >> ${LOG_FILE} 2>&1

# Check if secrets exist
if [ ! -f ${SREGISTRY_CLIENT_SECRETS} ]; then
    echo "No SRegistry secrets found: ${SREGISTRY_CLIENT_SECRETS}" >> ${LOG_FILE} 2>&1
    echo "You have to upload such file first on HPC resources" >> ${LOG_FILE} 2>&1
    exit 1
fi

if [ ! -d ${SREGISTRY_STORAGE} ]; then
    mkdir -p ${SREGISTRY_STORAGE}
fi
				      
# Get Singularity image if not already installed
if [ ! -f ${SREGISTRY_STORAGE}/$IMAGE_NAME ]; then
   isSregistry=$(which sregistry)
   if  [ "$isSregistry" != "" ] && [ ${SREGISTRY_URL} != "" ] && [ ${SREGISTRY_IMAGE} != "" ]; then
       echo "Get ${IMAGE_NAME} using sregistry-cli" >> ${LOG_FILE} 2>&1
       # On Lnmci
       echo "sregistry get ${IMAGE_URI} >> ${LOG_FILE} 2>&1"
       sregistry pull ${IMAGE_URI} >> ${LOG_FILE} 2>&1
       echo "sregistry rename ${IMAGE_URI} ${IMAGE_NAME} >> ${LOG_FILE} 2>&1"
       sregistry rename ${IMAGE_URI} ${IMAGE_NAME} >> ${LOG_FILE} 2>&1
       
   else
       echo "Get $IMAGE_URI ($IMAGE_NAME) using intermediate shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE}" >> ${LOG_FILE} 2>&1
       # On Cesga:
       singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} pull ${IMAGE_URI} 2>&1 >> ${LOG_FILE} 2>&1
       status=$?
       echo "singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} pull ${IMAGE_URI} (status=$status)" >> ${LOG_FILE} 2>&1
       if [ $status != "0" ]; then
	   echo "singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} pull ${IMAGE_URI}: FAILS"
	   exit 1
       fi
       echo "Rename $IMAGE_URI to $IMAGE_NAME" >> ${LOG_FILE} 2>&1
       singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} rename ${IMAGE_URI} ${IMAGE_NAME} >> ${LOG_FILE} 2>&1
       status=$?
       echo "singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} rename ${IMAGE_URI} ${IMAGE_NAME} (status=$status)" >> ${LOG_FILE} 2>&1
       if [ $status != "0" ]; then
	   echo "singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} rename ${IMAGE_URI}: FAILS"
	   exit 1
       fi
   fi
fi

# Get data from ckan
if [ "x$REMOTE_URL" != "x" ] && [ "$REMOTE_URL" != "None" ]; then
    wget $REMOTE_URL >> ${LOG_FILE}
    ARCHIVE=$(basename $REMOTE_URL) >> ${LOG_FILE} 2>&1
    tar zxvf $ARCHIVE >> ${LOG_FILE} 2>&1
fi

# ctx logger info "Some logging"
# # read access
# ctx node properties tasks
