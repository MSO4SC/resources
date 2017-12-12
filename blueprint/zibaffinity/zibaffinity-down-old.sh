#!/bin/bash

sys=$1
if [ -z ${sys+x} ]; then 
	sys="zibaffinity"
	#sys="test"
fi

#cd zibaffinity
echo "Uninstalling deployment.."
cfy executions start -d ${sys} uninstall #--force
echo "Deleting deployment.."
cfy deployments delete ${sys} #--force
echo "Deleting blueprint.."
cfy blueprints delete ${sys}
