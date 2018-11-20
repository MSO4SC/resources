#!/bin/bash
cd app
echo "Uninstalling deployment.."
cfy executions start -f -d single-singularity-im uninstall -p ignore_failure=true
echo "Deleting deployment.."
cfy deployments delete single-singularity-im
echo "Deleting blueprint.."
cfy blueprints delete single-singularity-im
