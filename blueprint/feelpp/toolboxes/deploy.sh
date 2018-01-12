#!/bin/bash

# Possible argument {up,down}

arg=$1

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/" && pwd )"
ROOT_DIR=${SCRIPT_DIR}/../../../
JOB=feelpp_toolboxes
UPLOAD_DIR=${SCRIPT_DIR}/upload
TOSCA=blueprint.yaml
LOCAL=local-blueprint-inputs.yaml
LOCAL_DIR=../../../../
LOCAL_APP_DIR=../config
LOCAL_APP=torsionbar

usage()
{
    echo "usage: $0 [CMD] config_name"
    echo ""
    echo "options:"
    echo "      up     send to orchestrator"
    echo "    down     remove from orchestrator"
    echo ""
    echo "config_name:"
    echo "    Base name of the config available in config directory."
    echo "    torsionbar example is used by default."
    echo ""
    echo "Example: ./deploy up torsionbar"
    echo "         ./deploy down torsionbar"
}

cd ${UPLOAD_DIR}

if [ ! -f "${LOCAL_DIR}/${LOCAL}" ]; then
    echo "${LOCAL_DIR}/${LOCAL} does not exist! See doc or blueprint examples!"
    exit 1
fi

case $arg in
    "up" )
        if [ -n $2 ]; then
            if [ -f ${LOCAL_APP_DIR}/$2.yaml ]; then
                LOCAL_APP=$2
            else
                echo "$2 file does not exist!"
                exit 1
            fi
        fi

        cfy blueprints upload -b "${JOB}" "${TOSCA}"
        read -n 1 -s -p "Press any key to continue"
        echo ''
        cfy deployments create -b "${JOB}" -i "${LOCAL_DIR}/${LOCAL}" -i "${LOCAL_APP_DIR}/${LOCAL_APP}.yaml" --skip-plugins-validation ${JOB}
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
        usage
        ;;
esac
