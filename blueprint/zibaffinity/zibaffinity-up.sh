#!/bin/bash

sys=$1
#sys="za"
if [ -z ${sys+x} ]; then 
	sys="zibaffinity"
	#sys="test"
fi

#cd zibaffinity
cfy blueprints upload -b ${sys}_bp blueprint.yaml
read -n 1 -s -p "Press any key to continue"
echo ''
cfy deployments create -b ${sys}_bp -i ./zibaffinity-inputs.yaml --skip-plugins-validation ${sys}
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d ${sys} install
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d ${sys} run_jobs   # workflow name 
