#!/bin/bash

# Possible argument {up,down}

arg=$1

ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/" && pwd )"
JOB=torsionbar_job
TOSCA=blueprint.yaml
LOCAL=mylocal.yaml

mkdir -p ${JOB}
cd ${JOB}
case $arg in
    "up" )
        cfy blueprints upload -b "${JOB}" "${ROOTDIR}/${TOSCA}"
        read -n 1 -s -p "Press any key to continue"
        echo ''
        cfy deployments create -b "${JOB}" -i "${ROOTDIR}/${LOCAL}" --skip-plugins-validation "${JOB}"
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
