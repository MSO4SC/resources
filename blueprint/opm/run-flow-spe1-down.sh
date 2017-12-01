#!/bin/bash
(
    cd run-flow-spe1
    echo "Uninstalling deployment.."
    cfy executions start -d run-flow-spe1 uninstall
    echo "Deleting deployment.."
    cfy deployments delete run-flow-spe1
    echo "Deleting blueprint.."
    cfy blueprints delete run-flow-spe1
)