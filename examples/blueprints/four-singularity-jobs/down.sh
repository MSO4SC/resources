#!/bin/bash
cd app
echo "Uninstalling deployment.."
cfy executions start -d four-singularity-job uninstall -p ignore_failure=true
echo "Deleting deployment.."
cfy deployments delete four-singularity-job
echo "Deleting blueprint.."
cfy blueprints delete four-singularity-job
