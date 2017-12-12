#!/bin/bash
cd four-jobs
cfy blueprints upload -b four-job blueprint.yaml
read -n 1 -s -p "Press any key to continue"
echo ''
cfy deployments create -b four-job -i ../local-blueprint-inputs.yaml --skip-plugins-validation four-job
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d four-job install
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d four-job run_jobs
