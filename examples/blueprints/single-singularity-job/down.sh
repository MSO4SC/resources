#!/bin/bash
cd app
echo "Uninstalling deployment.."
cfy executions start -d single-singularity-job uninstall
echo "Deleting deployment.."
cfy deployments delete single-singularity-job
echo "Deleting blueprint.."
cfy blueprints delete single-singularity-job
