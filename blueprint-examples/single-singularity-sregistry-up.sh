#!/bin/bash
cd single-singularity-sregistry-job
cfy blueprints upload -b single-singularity-sregistry-job blueprint.yaml
read -n 1 -s -p "Press any key to continue"
echo ''
cfy deployments create -b single-singularity-sregistry-job -i ../local-blueprint-inputs.yaml --skip-plugins-validation single-singularity-sregistry-job
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d single-singularity-sregistry-job install
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d single-singularity-sregistry-job run_jobs
