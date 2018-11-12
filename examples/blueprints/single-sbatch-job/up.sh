#!/bin/bash
cd app
cfy blueprints upload -b single-sbatch-job blueprint.yaml
read -n 1 -s -p "Press any key to continue"
echo ''
cfy deployments create -b single-sbatch-job -i ../../inputs/local-blueprint-inputs.yaml --skip-plugins-validation single-sbatch-job
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d single-sbatch-job install
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d single-sbatch-job run_jobs
