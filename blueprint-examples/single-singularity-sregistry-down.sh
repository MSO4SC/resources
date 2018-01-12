#!/bin/bash
cd single-singularity-sregistry-job
echo "Uninstalling deployment.."
cfy executions start -d single-singularity-sregistry-job uninstall
echo "Deleting deployment.."
cfy deployments delete single-singularity-sregistry-job
echo "Deleting blueprint.."
cfy blueprints delete single-singularity-sregistry-job
