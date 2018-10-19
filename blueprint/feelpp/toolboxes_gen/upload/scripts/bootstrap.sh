#!/bin/bash -l

module load singularity/2.4.2

WORKDIR=$1
URI=$2
FILE=$3

# mkdir -p $WORKDIR
# if [ ! -f $WORKDIR/$FILE ]; then
#     cd $WORKDIR
#     singularity pull --name $FILE $URI &> ../bootstrap.log
# fi

singularity check $FILE &>> bootstrap.log 2>&1

JOB_LOG_FILTER_FILE="logfilter.yaml"
read -r -d '' JOB_LOG_FILTER <<"EOF"
[
    {
        "filename": "job.log",
        "filters": []

}
]
EOF
echo "${JOB_LOG_FILTER}" > $JOB_LOG_FILTER_FILE
echo "[INFO] $(hostname):$(date) JOb log fiter: Created" >> bootstrap.log


singularity pull --name remotelogger-cli.simg shub://sregistry.srv.cesga.es/mso4sc/remotelogger-cli:latest
echo "[INFO] $(hostname):$(date) Remotelogger-cli: Downloaded" >> bootstrap.log

echo "[INFO] $(hostname):$(date) Bootstrap finished succesfully!" >> bootstrap.log
