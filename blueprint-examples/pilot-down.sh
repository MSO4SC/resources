#!/bin/bash
cd pilot-example
echo "Uninstalling deployment.."
cfy executions start -d pilot uninstall
echo "Deleting deployment.."
cfy deployments delete pilot
echo "Deleting blueprint.."
cfy blueprints delete pilot
