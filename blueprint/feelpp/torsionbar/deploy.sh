#!/bin/bash

# Possible argument {up,down}

arg=$1

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/" && pwd )"
ROOT_DIR=${SCRIPT_DIR}/../../../
JOB=torsionbar_job
UPLOAD_DIR=${SCRIPT_DIR}/upload
TOSCA=blueprint.yaml
LOCAL=local-blueprint-inputs.yaml
LOCAL_DIR=../../../../

if [ ! -f "${ROOT_DIR}/${LOCAL}" ]; then
    echo "${ROOT_DIR}/${LOCAL} does not exist! See doc or blueprint examples!"
    exit 1
fi

cd ${UPLOAD_DIR}

case $arg in
    "up" )
        cfy blueprints upload -b "${JOB}" "${TOSCA}"
        read -n 1 -s -p "Press any key to continue"
        echo ''
        cfy deployments create -b "${JOB}" -i "${LOCAL_DIR}/${LOCAL}" --skip-plugins-validation ${JOB}
        read -n 1 -s -p "Press any key to continue"
        echo ''
        cfy executions start -d "${JOB}" install
        read -n 1 -s -p "Press any key to continue"
        echo ''
        cfy executions start -d "${JOB}" run_jobs
        ;;

    "down" )
        echo "Uninstalling deployment ${JOB}..."
        cfy executions start -d "${JOB}" uninstall
        echo "Deleting deployment ${JOB}..."
        cfy deployments delete "${JOB}"
        echo "Deleting blueprint ${JOB}..."
        cfy blueprints delete "${JOB}"
        ;;
    *)
        echo "usage: $0 [option]"
        echo ""
        echo "options:"
        echo "      up     send to orchestrator"
        echo "    down     remove from orchestrator"
        echo ""
        ;;
esac
