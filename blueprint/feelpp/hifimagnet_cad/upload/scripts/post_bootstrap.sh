#!/bin/bash -l

# set -euo pipefail
# set -x

# Custom logs
LOG_FILE=$0.log

echo "bootstrap" >> "${LOG_FILE}"
echo "parameters: $*" >> "${LOG_FILE}"

# params for singularity images:
# $1 - { get_input: sregistry_storage }
# $2 - { get_input: sregistry_client }
# $3 - { get_input: sregistry_secrets } 
# $4 - { get_input: sregistry_url }
# $5 - { get_input: sregistry_image } 

# $6 - {get_input: cadcfg}
# $7 - name of the job

export SREGISTRY_STORAGE=$1 >> "${LOG_FILE}"
export SREGISTRY_CLIENT=$2 >> "${LOG_FILE}"
export SREGISTRY_CLIENT_SECRETS=$3 >> "${LOG_FILE}"
SREGISTRY_URL=$4
SREGISTRY_IMAGE=$5

# Check if secrets exist
if [ ! -f "${SREGISTRY_CLIENT_SECRETS}" ]; then
    echo "No SRegistry secrets found: ${SREGISTRY_CLIENT_SECRETS}" >> "${LOG_FILE}"
    echo "You have to upload such file first on HPC resources" >> "${LOG_FILE}"
    exit 1
fi

if [ ! -d "${SREGISTRY_STORAGE}" ]; then
    mkdir -p "${SREGISTRY_STORAGE}"
fi

getimage(){

    local URI=$1
    URI_NAME=$(echo "${URI}" | tr '/' '-' |  tr ':' '-')

    echo "getimage: ${URI} (${SREGISTRY_STORAGE}/${URI_NAME})"
    
    # module should be optional:
    isSregistry=""
    isSingularity=""
    isModule=$(compgen -A function | grep  module)
    if [ "$isModule" != "" ]; then
	module load singularity >> "${LOG_FILE}"
    else
	isSregistry=$(which sregistry)
	isSingularity=$(which singularity)
	if  [ "$isSregistry" = "" ] &&  [ "$isSingularity" = "" ]; then
	    echo "either sregistry or singularity is mandatory: please install one of them" >> "${LOG_FILE}"
	    exit 1
	fi
    fi

    # Get Singularity image if not already installed
    if [ ! -f "${SREGISTRY_STORAGE}/${URI_NAME}".simg ]; then
	if  [ "$isSregistry" != "" ] && [ "${SREGISTRY_URL}" != "" ] && [ "${SREGISTRY_IMAGE}" != "" ]; then
	    echo "Get ${IMAGE} using sregistry-cli" >> "${LOG_FILE}"
	    # On Lnmci
	    sregistry pull "${URI}" >> "${LOG_FILE}" 2>&1
	    status=$?
	    if [ $status != "0" ]; then
		echo "sregistry pull ${URI}: FAILS" >> "${LOG_FILE}"
		exit 1
	    fi
	else
	    SREGISTRY_NAME=$(echo "${SREGISTRY_IMAGE}" | tr '/' '-' |  tr ':' '-')
	    if [ ! -f "${SREGISTRY_STORAGE}/${SREGISTRY_NAME}".simg ]; then
		echo "Get $SREGISTRY_IMAGE ($SREGISTRY_NAME) using intermediate shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE}" >> "${LOG_FILE}"
		singularity run -B /mnt shub://"${SREGISTRY_URL}"/"${SREGISTRY_IMAGE}" --quiet pull "${SREGISTRY_IMAGE}" >> "${LOG_FILE}" 2>&1
		status=$?
		if [ $status != "0" ]; then
		    echo "singularity run -B /mnt shub://${SREGISTRY_URL}/${SREGISTRY_IMAGE} --quiet pull ${SREGISTRY_IMAGE}: FAILS" >> "${LOG_FILE}"
		    exit 1
		fi
	    fi
	    # On Cesga:
	    singularity run -B /mnt "${SREGISTRY_STORAGE}/${SREGISTRY_NAME}".simg --quiet pull "${URI}" >> "${LOG_FILE}" 2>&1
	    status=$?
	    if [ $status != "0" ]; then
		echo "singularity run -B /mnt ${SREGISTRY_STORAGE}/${SREGISTRY_NAME}.simg --quiet pull ${URI}: FAILS" >> "${LOG_FILE}"
		exit 1
	    fi
	fi
    fi
}

# Ckan:
DATA=""

# Logger
NAME=""

if [ "$nargs" -ge 6 ]; then
    DATA=${6}
fi
if [ "$nargs" -ge 7 ]; then
    NAME=${7}
fi

cat > create_arch.sh <<"EOF"
#!/bin/bash

singularity run -B /mnt \
  STORAGE/mso4sc-remotelogger-cli-latest.simg \
  -f post_logfilter.yaml -sh logging.mso4sc.eu -u mso4sc -p remotelogger -rk $2 -q hifimagnet > post_logger0.log 2>&1 &


tar zcvf $1.tgz *.xao *.brep *.med > post.log 2>&1  
EOF

chmod u+x create_arch.sh


################################################################################
# see: https://github.com/MSO4SC/resources/blob/master/blueprint-examples/opm-flow-logger/scripts/singularity_bootstrap_run-flow-generic.sh
# add a "filters": [] within each filename
# eg:
# "filters": [
#     {pattern: "^================    End of simulation     ===============", severity: "OK",   progress: 100},
#     {pattern: "^Time step",  severity: "INFO"},
#     {pattern: "^Report step",  severity: "WARNING", progress: "+1"},
#     {pattern: "^[\\\\s]*[:|=]", verbosity: 2},
#     {pattern: "^Keyword", verbosity: 2},
#     {pattern: "[\\\\s\\\\S]*", verbosity: 1},
# ]
#
# Add logging part

if [ ! -f post_logfilter.yaml ]; then
    JOB_LOG_FILTER_FILE="post_logfilter.yaml"
    read -r -d '' JOB_LOG_FILTER <<"EOF"
[   
    {
        "filename": "post.log",
        "filters": []
    }
]
EOF
    echo "${JOB_LOG_FILTER}" > $JOB_LOG_FILTER_FILE
    echo "[INFO] $(hostname):$(date) Job log fiter: Created" >> "${LOG_FILE}"

    getimage "mso4sc/remotelogger-cli:latest" 
    status=$?
    if [ $status != "0" ]; then
	exit 1
    fi

    # singularity pull --name remotelogger-cli.simg shub://sregistry.srv.cesga.es/mso4sc/remotelogger-cli:latest
    echo "[INFO] $(hostname):$(date) Remotelogger-cli: Downloaded"  >> "${LOG_FILE}"
    echo "[INFO] $(hostname):$(date) Bootstrap finished succesfully!" >> "${LOG_FILE}"
fi

##################
