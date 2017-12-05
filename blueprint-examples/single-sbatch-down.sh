#!/bin/bash
cd single-sbatch-job
echo "Uninstalling deployment.."
cfy executions start -d single-sbatch-job uninstall
echo "Deleting deployment.."
cfy deployments delete single-sbatch-job
echo "Deleting blueprint.."
cfy blueprints delete single-sbatch-job
