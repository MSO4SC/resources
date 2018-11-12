#!/bin/bash
cd app
cfy blueprints upload -b single-sbatch-output blueprint.yaml
read -n 1 -s -p "Press any key to continue"
echo ''
cfy deployments create -b single-sbatch-output -i ../../inputs/local-blueprint-inputs.yaml --skip-plugins-validation single-sbatch-output
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d single-sbatch-output install
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d single-sbatch-output run_jobs
