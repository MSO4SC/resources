#!/bin/bash

# Possible argument {up,down}

arg=$1

JOB=torsionbar_job

mkdir -p ${JOB}
cd ${JOB}
case $arg in
    "up" )
        cfy blueprints upload -b ${JOB}  torsionbar.yaml
        read -n 1 -s -p "Press any key to continue"
        echo ''
        cfy deployments create -b ${JOB} -i ./mylocal.yaml --skip-plugins-validation ${JOB}
        read -n 1 -s -p "Press any key to continue"
        echo ''
        cfy executions start -d ${JOB} install
        read -n 1 -s -p "Press any key to continue"
        echo ''
        cfy executions start -d ${JOB} run_jobs
        ;;

    "down" )
        echo "Uninstalling deployment.."
        cfy executions start -d ${JOB} uninstall
        echo "Deleting deployment.."
        cfy deployments delete ${JOB}
        echo "Deleting blueprint.."
        cfy blueprints delete ${JOB}
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
