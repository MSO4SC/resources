#!/bin/bash
set -e
(
    cd run-flow-ensemble
    cfy blueprints upload -b run-flow-ensemble blueprint.yaml
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy deployments create -b run-flow-ensemble -i ../local-blueprint-inputs.yaml --skip-plugins-validation run-flow-ensemble
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy executions start -d run-flow-ensemble install
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy executions start -d run-flow-ensemble run_jobs
)
