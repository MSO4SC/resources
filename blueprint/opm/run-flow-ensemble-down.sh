#!/bin/bash
(
    cd run-flow-ensemble
    echo "Uninstalling deployment.."
    cfy executions start -d run-flow-ensemble uninstall
    echo "Deleting deployment.."
    cfy deployments delete run-flow-ensemble
    echo "Deleting blueprint.."
    cfy blueprints delete run-flow-ensemble
)
