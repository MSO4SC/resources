#!/bin/bash
cd app
cfy -v blueprints upload -b single-singularity-im blueprint.yaml

echo ''
cfy deployments create -b single-singularity-im -i ../../../inputs/local-blueprint-inputs.yaml --skip-plugins-validation single-singularity-im

echo ''
cfy executions start -d single-singularity-im install

echo ''
cfy executions start -d single-singularity-im run_jobs
