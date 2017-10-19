#!/bin/bash
cd pilot-example
cfy blueprints upload -b pilot pilot-blueprint.yaml
read -n 1 -s -p "Press any key to continue"
echo ''
cfy deployments create -b pilot -i ../local-blueprint-inputs.yaml --skip-plugins-validation pilot
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d pilot install
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d pilot run_jobs
