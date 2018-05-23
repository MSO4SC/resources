#!/bin/bash

# Possible argument {up,down}

arg=$1

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/" && pwd )"
ROOT_DIR=${SCRIPT_DIR}/../../../
UPLOAD_DIR=${SCRIPT_DIR}/upload
JOB=feelpp_toolboxes_3j
APP=feelpp_toolboxes_3j
TOSCA=blueprint.yaml
LOCAL=local-blueprint-inputs.yaml
LOCAL_DIR=../../../../

usage()
{
    echo "usage: $0 [CMD] config_name"
    echo ""
    echo "options:"
    echo "      up     send to orchestrator"
    echo "    down     remove from orchestrator"
    echo "     pkg     create a package for marketplace (For portal usage)"
    echo ""
    echo "config_name:"
    echo "    Base name of the config available in config directory."
    echo "    torsionbar example is used by default."
    echo ""
    echo "Example: ./deploy up"
    echo "         ./deploy down"
    echo "         ./deploy pkg"
}


if [ ! -f "${ROOT_DIR}/${LOCAL}" ]; then
    echo "${ROOT_DIR}/${LOCAL} does not exist! See doc or blueprint examples!"
    exit 1
fi


case $arg in
    "up" )
        cd ${UPLOAD_DIR}
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
        cd ${UPLOAD_DIR}
        echo "Uninstalling deployment ${JOB}..."
        cfy executions start -d "${JOB}" uninstall
        echo "Deleting deployment ${JOB}..."
        cfy deployments delete "${JOB}"
        echo "Deleting blueprint ${JOB}..."
        cfy blueprints delete "${JOB}"
        ;;

    "pkg")
        cd ${SCRIPT_DIR}
        echo "Creating package..."
        export COPYFILE_DISABLE=1
        tar --transform s/^upload/${APP}/ -cvzf "${APP}.tar" upload
        ;;

    *)
        usage
        ;;
esac
