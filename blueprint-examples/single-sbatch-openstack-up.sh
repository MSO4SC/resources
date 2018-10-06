#!/bin/bash
cd single-sbatch-openstack
cfy blueprints upload -b sbatch-openstack blueprint.yaml
read -n 1 -s -p "Press any key to continue"
echo ''
cfy deployments create -b sbatch-openstack -i ../local-blueprint-openstack-inputs.yaml --skip-plugins-validation sbatch-openstack
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d sbatch-openstack install
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d sbatch-openstack run_jobs
