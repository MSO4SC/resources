#!/bin/bash -l

# set -euo pipefail
# set -x

# Custom logs
LOG_FILE=$0.log

echo "bootstrap" >> "${LOG_FILE}"
echo "parameters: $*" >> "${LOG_FILE}"

nargs=$#
echo "nargs: $nargs" >> "${LOG_FILE}"
echo "last arg: ${!nargs}" >> "${LOG_FILE}"

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
# $11 - { get_input: mso4sc_datacatalogue_key }

# input file
# $12 - {get_input: cadcfg}

export SREGISTRY_STORAGE=$1 >> ${LOG_FILE}

IMAGE_NAME=$2
IMAGE_URI=$3
# IMAGE_CLEANUP=$4

export SREGISTRY_CLIENT=$5
export SREGISTRY_CLIENT_SECRETS=$6

echo "SREGISTRY_STORAGE=$SREGISTRY_STORAGE" >> ${LOG_FILE} 2>&1
echo "SREGISTRY_CLIENT=$SREGISTRY_CLIENT" >> ${LOG_FILE} 2>&1
echo "SREGISTRY_CLIENT_SECRETS=$SREGISTRY_CLIENT_SECRETS" >> ${LOG_FILE} 2>&1

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
DATASET=""
CATALOGUE_TOKEN=""
DATA=""

if [ "$nargs" -ge 10 ]; then
    DATASET=${10}
fi
if [ "$nargs" -ge 11 ]; then
    CATALOGUE_TOKEN=${11}
fi
if [ "$nargs" -ge 12 ]; then
    DATA=${12}
fi


echo "${SREGISTRY_URL}" >> "${LOG_FILE}"
echo "${SREGISTRY_IMAGE}" >> "${LOG_FILE}"

# module should be optional:
isModule=$(compgen -A function | grep  module)
if [ "$isModule" != "" ]; then
    module load singularity >> "${LOG_FILE}"
fi

# Singularity image retrieved from
# https://www.singularity-hub.org/collections/253

echo "CURRENT_WORKIR=$CURRENT_WORKDIR" >> "${LOG_FILE}"
echo "IMAGE_NAME=$IMAGE_NAME" >> "${LOG_FILE}"
echo "IMAGE_URI=$IMAGE_URI" >> "${LOG_FILE}"

echo "SREGISTRY_STORAGE=${SREGISTRY_STORAGE}" >> "${LOG_FILE}"
echo "SREGISTRY_URL=${SREGISTRY_URL}" >> "${LOG_FILE}"
echo "SREGISTRY_IMAGE=${SREGISTRY_IMAGE}" >> "${LOG_FILE}"

# Check if secrets exist
if [ ! -f "${SREGISTRY_CLIENT_SECRETS}" ]; then
    echo "No SRegistry secrets found: ${SREGISTRY_CLIENT_SECRETS}" >> "${LOG_FILE}"
    echo "You have to upload such file first on HPC resources" >> "${LOG_FILE}"
    exit 1
fi

if [ ! -d "${SREGISTRY_STORAGE}" ]; then
    mkdir -p "${SREGISTRY_STORAGE}"
fi
				      
# Get Singularity image if not already installed
if [ ! -f "${SREGISTRY_STORAGE}/${IMAGE_NAME}" ]; then
   isSregistry=$(which sregistry)
   if  [ "$isSregistry" != "" ] && [ "${SREGISTRY_URL}" != "" ] && [ "${SREGISTRY_IMAGE}" != "" ]; then
       echo "Get ${IMAGE_NAME} using sregistry-cli" >> "${LOG_FILE}"
       # On Lnmci
       sregistry pull "${IMAGE_URI}" >> "${LOG_FILE}" 2>&1
       status=$?
       if [ $status != "0" ]; then
	   echo "sregistry pull ${IMAGE_URI}: FAILS" >> "${LOG_FILE}"
	   exit 1
       fi
   else
       SREGISTRY_NAME=$(echo ${SREGISTRY_IMAGE} | tr '/' '-' |  tr ':' '-')
       if [ ! -f "${SREGISTRY_STORAGE}/${SREGISTRY_NAME}" ]; then
           echo "Get $SREGISTRY_IMAGE ($SREGISTRY_NAME) using intermediate shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE}" >> "${LOG_FILE}"
	   singularity run -B /mnt shub://"${SREGISTRY_URL}"/"${SREGISTRY_IMAGE}" --quiet pull "${SREGISTRY_IMAGE}" >> "${LOG_FILE}" 2>&1
           if [ $status != "0" ]; then
	       echo "singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} --quiet pull ${SREGISTRY_IMAGE}: FAILS" >> "${LOG_FILE}"
	       exit 1
           fi
       fi
       # On Cesga:
       singularity run -B /mnt "${SREGISTRY_STORAGE}/${SREGISTRY_NAME}".simg --quiet pull "${IMAGE_URI}" >> "${LOG_FILE}" 2>&1
       status=$?
       if [ $status != "0" ]; then
	   echo "singularity run -B /mnt ${SREGISTRY_STORAGE}/${SREGISTRY_NAME}.simg --quiet pull ${IMAGE_URI}: FAILS" >> "${LOG_FILE}"
	   exit 1
       fi
   fi
fi

# Get data from ckan
echo "DATASET=${DATASET}" >> "${LOG_FILE}"
echo "CATALOGUE_TOKEN=${CATALOGUE_TOKEN}" >> "${LOG_FILE}"
echo "DATA=${DATA}" >> "${LOG_FILE}"

ARCHIVE=${DATASET}
ARCHIVE=$(echo $ARCHIVE | perl -pi -e "s|.*/||")
isstatus=$?
if [ "$isstatus" == 1 ]; then
    exit 1
fi    
echo "ARCHIVE=$ARCHIVE"  >> "${LOG_FILE}"

OPTIONS=""
if [ "$CATALOGUE_TOKEN" ]; then
    OPTIONS="-H \"Authorization: ${CATALOGUE_TOKEN}\""
fi

if [ "x$DATASET" != "x" ] && [ "$DATASET" != "None" ]; then
    echo "curl $OPTIONS $DATASET -o $ARCHIVE" >> "${LOG_FILE}"
    if [ "$CATALOGUE_TOKEN" ]; then
	curl -H "Authorization: ${CATALOGUE_TOKEN}" $DATASET -o $ARCHIVE
	isDownloaded=$?
    else
	curl $DATASET -o $ARCHIVE
	isDownloaded=$?
    fi
    if [ "$isDowloaded" == 1 ]; then
	echo "curl $OPTIONS $DATASET -o $ARCHIVE : FAILS" >> "${LOG_FILE}"
        exit 1
    fi
    
    TYPE=$(file $ARCHIVE | perl -pi -e "s|$ARCHIVE: ||")
    echo "type($ARCHIVE)=$TYPE"  >> "${LOG_FILE}"

    tar zxvf "$ARCHIVE" >> "${LOG_FILE}"
    status=$?
    if [ $status != "0" ]; then
	echo "tar zxvf $ARCHIVE : FAILS" >> "${LOG_FILE}"
	exit 1
    fi

    # check if input file is present
    if [ ! -z $DATA ]; then
     if [ ! -f "$DATA" ]; then
	echo "$DATA: no such file in dataset $DATASET" >> "${LOG_FILE}"
	exit 1
     fi
    fi
fi

# ctx logger info "Some logging"
# # read access
# ctx node properties tasks
