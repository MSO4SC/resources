#!/bin/bash
cd app
echo "Uninstalling deployment.."
cfy executions start -d four-job uninstall -p ignore_failure=true
echo "Deleting deployment.."
cfy deployments delete four-job
echo "Deleting blueprint.."
cfy blueprints delete four-job
