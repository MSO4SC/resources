#!/bin/bash
(
    cd run-flow-norne
    echo "Uninstalling deployment.."
    cfy executions start -d run-flow-norne-2p uninstall
    echo "Deleting deployment.."
    cfy deployments delete run-flow-norne-2p
    echo "Deleting blueprint.."
    cfy blueprints delete run-flow-norne-2p
)
