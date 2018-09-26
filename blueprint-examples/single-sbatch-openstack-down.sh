#!/bin/bash
cd single-sbatch-openstack
echo "Uninstalling deployment.."
cfy executions start -d sbatch-openstack uninstall -p ignore_failure=true
echo "Deleting deployment.."
cfy deployments delete sbatch-openstack
echo "Deleting blueprint.."
cfy blueprints delete sbatch-openstack
