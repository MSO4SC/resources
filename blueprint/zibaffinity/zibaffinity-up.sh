#!/bin/bash

sys=$1
if [ -z ${sys+x} ]; then 
	sys="zibaffinity"
	#sys="test"
fi

#cd zibaffinity
cfy blueprints upload -b ${sys}_bp zibaffinity.yaml
read -n 1 -s -p "Press any key to continue"
echo ''
cfy deployments create -b ${sys}_bp -i ./zibaffinity-inputs.yaml --skip-plugins-validation ${sys}_depl
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d ${sys}_depl install
read -n 1 -s -p "Press any key to continue"
echo ''
cfy executions start -d ${sys}_depl run_jobs   # workflow name 
