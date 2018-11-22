#!/bin/bash
cd $1
echo "Uninstalling deployment.."
cfy executions start -f -d $1 uninstall -p ignore_failure=true
echo "Deleting deployment.."
cfy deployments delete $1
echo "Deleting blueprint.."
cfy blueprints delete $1
