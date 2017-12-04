#!/bin/bash
(
    cd run-flow-norne
    echo "Uninstalling deployment.."
    cfy executions start -d run-flow-norne uninstall
    echo "Deleting deployment.."
    cfy deployments delete run-flow-norne
    echo "Deleting blueprint.."
    cfy blueprints delete run-flow-norne
)
