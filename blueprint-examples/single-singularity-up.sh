#!/bin/bash
cd single-singularity-job
cfy blueprints upload -b single-singularity-job single-singularity-blueprint.yaml
read -n 1 -s -p "Press any key to continue"
echo ''
cfy deployments create -b single-singularity-job -i ../local-blueprint-inputs.yaml --skip-plugins-validation single-singularity-job
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d single-singularity-job install
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d single-singularity-job run_jobs
