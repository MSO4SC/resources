#!/bin/bash
(
    cd floatingWT
    echo "Uninstalling deployment.."
    cfy executions start -d floatingWT uninstall
    echo "Deleting deployment.."
    cfy deployments delete floatingWT
    echo "Deleting blueprint.."
    cfy blueprints delete floatingWT
)
