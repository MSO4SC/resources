#!/bin/bash
set -e
(
    cd run-flow-generic
    cfy blueprints upload -b run-flow-generic blueprint.yaml
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy deployments create -b run-flow-generic -i ../local-blueprint-inputs.yaml --skip-plugins-validation run-flow-generic
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy executions start -d run-flow-generic install
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy executions start -d run-flow-generic run_jobs
)
