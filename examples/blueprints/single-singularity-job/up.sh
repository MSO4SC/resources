#!/bin/bash
cd app
cfy blueprints upload -b single-singularity-job blueprint.yaml
read -n 1 -s -p "Press any key to continue"
echo ''
cfy deployments create -b single-singularity-job -i ../../inputs/local-blueprint-inputs.yaml --skip-plugins-validation single-singularity-job
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d single-singularity-job install
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d single-singularity-job run_jobs
