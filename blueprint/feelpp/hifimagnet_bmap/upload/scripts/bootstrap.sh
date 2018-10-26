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
# $1 - { get_input: sregistry_storage }
# $2 - { get_input: singularity_image_filename - aka collection/}
# $3 - { get_input: singularity_image_uri }
# $4 - { get_input: singularity_image_cleanup }
# $5 - { get_input: sregistry_client }
# $6 - { get_input: sregistry_secrets } 
# $7 - { get_input: sregistry_url }
# $8 - { get_input: sregistry_image } 

# params fo input data
# $9 - { get_input: mso4sc_datacatalogue_key }
# $10 - { get_input: mso4sc_dataset_model }

# input data
Currents=${12}
Rdata=${13}
Zdata=${14}

Helix_current=$(echo "$Currents" |tr -d "[" | tr -d "]" | cut -d ":" -f1)
Bitter_current=$(echo "$Currents" |tr -d "[" | tr -d "]"  |cut -d ":" -f2)
Supra_current=$(echo "$Currents" |tr -d "[" | tr -d "]"  |cut -d ":" -f3)
R_max=$(echo "$Rdata" |tr -d "[" | tr -d "]"  |cut -d ":" -f1)
R_min=$(echo "$Rdata" |tr -d "[" | tr -d "]"  |cut -d ":" -f2)
N_R=$(echo "$Rdata" |tr -d "[" | tr -d "]"  |cut -d ":" -f3)
Z_max=$(echo "$Zdata" |tr -d "[" | tr -d "]"  |cut -d ":" -f1)
Z_min=$(echo "$Zdata" |tr -d "[" | tr -d "]"  |cut -d ":" -f2)
N_Z=$(echo "$Zdata" |tr -d "[" | tr -d "]"  |cut -d ":" -f3)

echo "Helix_current=${Helix_current}" >> "${LOG_FILE}"
echo "Bitter_current=${Bitter_current}" >> "${LOG_FILE}"
echo "Supra_current=${Supra_current}" >> "${LOG_FILE}"
echo "R_max=${R_max}" >> "${LOG_FILE}"
echo "R_min=${R_min}" >> "${LOG_FILE}"
echo "N_R=${N_R}" >> "${LOG_FILE}"
echo "Z_max=${Z_max}" >> "${LOG_FILE}"
echo "Z_min=${Z_min}" >> "${LOG_FILE}"
echo "N_Z=${N_Z}"  >> "${LOG_FILE}"


export SREGISTRY_STORAGE=$1 >> "${LOG_FILE}"

IMAGE_NAME=$2
IMAGE_URI=$3
# IMAGE_CLEANUP=$4

export SREGISTRY_CLIENT=$5 >> "${LOG_FILE}"
export SREGISTRY_CLIENT_SECRETS=$6 >> "${LOG_FILE}"

SREGISTRY_URL=$7
SREGISTRY_IMAGE=$8

# Ckan:
DATASET=""
CATALOGUE_TOKEN=""
DATA=""

if [ "$nargs" -ge 10 ]; then
    DATASET=${10}
fi
if [ "$nargs" -ge 9 ]; then
    CATALOGUE_TOKEN=${9}
fi
if [ "$nargs" -ge 11 ]; then
    DATA=${11}
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
if [ ! -f "${SREGISTRY_STORAGE}/$IMAGE_NAME" ]; then
   isSregistry=$(which sregistry)
   if  [ "$isSregistry" != "" ] && [ "${SREGISTRY_URL}" != "" ] && [ "${SREGISTRY_IMAGE}" != "" ]; then
       echo "Get ${IMAGE_NAME} using sregistry-cli" >> "${LOG_FILE}"
       # On Lnmci
       sregistry pull "${IMAGE_URI}" >> "${LOG_FILE}" 2>&1
       status=$?
       if [ $status != "0" ]; then
	   echo "sregistry get ${IMAGE_URI}: FAILS" >> "${LOG_FILE}"
	   exit 1
       fi
       sregistry rename "${IMAGE_URI}" "${IMAGE_NAME}" >> "${LOG_FILE}" 2>&1
       status=$?
       if [ $status != "0" ]; then
	   echo "sregistry rename ${IMAGE_URI} ${IMAGE_NAME}: FAILS" >> "${LOG_FILE}"
	   exit 1
       fi
       
   else
       echo "Get $IMAGE_URI ($IMAGE_NAME) using intermediate shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE}" >> "${LOG_FILE}"
       # On Cesga:
       singularity run -B /mnt shub://"${SREGISTRY_URL}"/"${SREGISTRY_IMAGE}" pull "${IMAGE_URI}" >> "${LOG_FILE}" 2>&1
       status=$?
       echo "singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} pull ${IMAGE_URI} (status=$status)" >> "${LOG_FILE}"
       if [ $status != "0" ]; then
	   echo "singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} pull ${IMAGE_URI}: FAILS" >> "${LOG_FILE}"
	   exit 1
       fi
       echo "Rename $IMAGE_URI to $IMAGE_NAME" >> "${LOG_FILE}"
       singularity run -B /mnt shub://"${SREGISTRY_URL}"/"${SREGISTRY_IMAGE}" rename "${IMAGE_URI}" "${IMAGE_NAME}" >> "${LOG_FILE}" 2>&1
       status=$?
       echo "singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} rename ${IMAGE_URI} ${IMAGE_NAME} (status=$status)" >> "${LOG_FILE}"
       if [ $status != "0" ]; then
	   echo "singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} rename ${IMAGE_URI}: FAILS" >> "${LOG_FILE}"
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
    # curl $OPTIONS $DATASET -o $ARCHIVE : Not working why???
    if [ "$CATALOGUE_TOKEN" ]; then
	curl -H "Authorization: ${CATALOGUE_TOKEN}" $DATASET -o $ARCHIVE
	isDownloaded=$?
    else
	curl $DATASET -o $ARCHIVE
	isDownloaded=$?
    fi
z
    # isDownloaded=$?
    if [ "$isDowloaded" == 1 ]; then
	echo "curl $OPTIONS $DATASET -o $ARCHIVE : FAILS" >> "${LOG_FILE}"
        exit 1
    fi
    
    TYPE=$(file $ARCHIVE | perl -pi -e "s|$ARCHIVE: ||")
    echo "type($ARCHIVE)=$TYPE"  >> "${LOG_FILE}"

    tar zxvf "$ARCHIVE" >> "${LOG_FILE}"

    # check if input file is present
    if [ ! -f "${DATA}.d" ]; then
	echo "${DATA}.d: no such file in dataset $DATASET"
	exit 1
    fi
    
fi

cat > input.in <<EOF
${Helix_current}
${Bitter_current}
EOF

# check if the are supra
if [ egrep "^1 " ${DATA}.d ]; then
    cat >> input.in <<EOF
    ${Supra_current}
EOF
fi

cat >> input.in <<EOF
${R_max}
${R_min}
${Z_max}
${Z_min}
${N_R}
${N_Z}
EOF

# ctx logger info "Some logging"
# # read access
# ctx node properties tasks
