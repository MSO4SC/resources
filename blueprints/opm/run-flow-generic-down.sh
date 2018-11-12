#!/bin/bash
(
    cd run-flow-generic
    echo "Uninstalling deployment.."
    cfy executions start -d run-flow-generic uninstall
    echo "Deleting deployment.."
    cfy deployments delete run-flow-generic
    echo "Deleting blueprint.."
    cfy blueprints delete run-flow-generic
)