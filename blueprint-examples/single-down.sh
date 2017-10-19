#!/bin/bash
cd single-job
echo "Uninstalling deployment.."
cfy executions start -d single-job uninstall
echo "Deleting deployment.."
cfy deployments delete single-job
echo "Deleting blueprint.."
cfy blueprints delete single-job
