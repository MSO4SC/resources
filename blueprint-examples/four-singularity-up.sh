#!/bin/bash
cd four-singularity-jobs
cfy blueprints upload -b four-singularity-job four-singularity-blueprint.yaml
read -n 1 -s -p "Press any key to continue"
echo ''
cfy deployments create -b four-singularity-job -i ../local-blueprint-inputs.yaml --skip-plugins-validation four-singularity-job
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d four-singularity-job install
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d four-singularity-job run_jobs
