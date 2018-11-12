#!/bin/bash
set -e
(
    cd floatingWT
    cfy blueprints upload -b floatingWT blueprint.yaml
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy deployments create -b floatingWT -i ../local-blueprint-inputs.yaml --skip-plugins-validation floatingWT
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy executions start -d floatingWT install
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy executions start -d floatingWT run_jobs
)
