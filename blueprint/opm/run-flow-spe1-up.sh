#!/bin/bash
(
    cd run-flow-spe1
    cfy blueprints upload -b run-flow-spe1 blueprint.yaml
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy deployments create -b run-flow-spe1 -i ../local-blueprint-inputs.yaml --skip-plugins-validation run-flow-spe1
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy executions start -d run-flow-spe1 install
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy executions start -d run-flow-spe1 run_jobs
)
