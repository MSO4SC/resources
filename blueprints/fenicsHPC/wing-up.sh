#!/bin/bash
set -e
(
    cd wing
    cfy blueprints upload -b wing blueprint.yaml
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy deployments create -b wing -i ../local-blueprint-inputs.yaml --skip-plugins-validation wing
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy executions start -d wing install
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy executions start -d wing run_jobs
)
