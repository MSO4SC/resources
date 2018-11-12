#!/bin/bash
cd app
echo "Uninstalling deployment.."
cfy executions start -d single-sbatch-output uninstall
echo "Deleting deployment.."
cfy deployments delete single-sbatch-output
echo "Deleting blueprint.."
cfy blueprints delete single-sbatch-output
