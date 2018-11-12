#!/bin/bash
set -e
(
    cd 3DAirQualityPredictionPilot
    cfy blueprints upload -b airQ blueprint.yaml
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy deployments create -b airQ -i ../local-blueprint-inputs.yaml --skip-plugins-validation airQ
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy executions start -d airQ install
    read -n 1 -s -p "Press any key to continue"
    echo ''
    cfy executions start -d airQ run_jobs
)
