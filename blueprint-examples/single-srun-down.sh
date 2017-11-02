#!/bin/bash
cd single-srun-job
echo "Uninstalling deployment.."
cfy executions start -d single-srun-job uninstall
echo "Deleting deployment.."
cfy deployments delete single-srun-job
echo "Deleting blueprint.."
cfy blueprints delete single-srun-job
