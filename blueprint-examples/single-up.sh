#!/bin/bash
cd single-job
cfy blueprints upload -b single-job single-blueprint.yaml
read -n 1 -s -p "Press any key to continue"
echo ''
cfy deployments create -b single-job -i ../local-blueprint-inputs.yaml --skip-plugins-validation single-job
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d single-job install
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d single-job run_jobs
