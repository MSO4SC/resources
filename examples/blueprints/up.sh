#!/bin/bash
set -e
cd $1
cp ../inputs-def.yaml ./
cfy -v blueprints upload -b $1 blueprint.yaml
rm inputs-def.yaml
echo ''
cfy deployments create -b $1 -i ../../inputs/local-blueprint-inputs.yaml --skip-plugins-validation $1

echo ''
cfy executions start -d $1 install

echo ''
cfy executions start -d $1 run_jobs
