#!/bin/bash
(
    cd run-flow-norne
    cfy blueprints upload -b run-flow-norne blueprint.yaml
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy deployments create -b run-flow-norne -i ../local-blueprint-inputs.yaml --skip-plugins-validation run-flow-norne
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy executions start -d run-flow-norne install
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy executions start --timeout=3600 -d run-flow-norne run_jobs
)
