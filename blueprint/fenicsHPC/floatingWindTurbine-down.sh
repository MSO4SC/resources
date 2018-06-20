#!/bin/bash
(
    cd floatingWindTurbine
    echo "Uninstalling deployment.."
    cfy executions start -d floatingWindTurbine uninstall
    echo "Deleting deployment.."
    cfy deployments delete floatingWindTurbine
    echo "Deleting blueprint.."
    cfy blueprints delete floatingWindTurbine
)
