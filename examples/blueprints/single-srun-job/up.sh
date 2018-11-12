#!/bin/bash
cd app
cfy blueprints upload -b single-srun-job blueprint.yaml
read -n 1 -s -p "Press any key to continue"
echo ''
cfy deployments create -b single-srun-job -i ../../inputs/local-blueprint-inputs.yaml --skip-plugins-validation single-srun-job
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d single-srun-job install
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d single-srun-job run_jobs
