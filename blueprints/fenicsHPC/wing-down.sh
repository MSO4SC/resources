#!/bin/bash
(
    cd wing
    echo "Uninstalling deployment.."
    cfy executions start -d wing uninstall
    echo "Deleting deployment.."
    cfy deployments delete wing
    echo "Deleting blueprint.."
    cfy blueprints delete wing
)
