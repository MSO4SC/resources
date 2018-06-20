#!/bin/bash
set -e
(
    cd floatingWindTurbine
    cfy blueprints upload -b floatingWindTurbine blueprint.yaml
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy deployments create -b floatingWindTurbine -i ../local-blueprint-inputs.yaml --skip-plugins-validation floatingWindTurbine
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy executions start -d floatingWindTurbine install
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy executions start -d floatingWindTurbine run_jobs
)
