#!/bin/bash
(
    cd 3DAirQualityPredictionPilot
    echo "Uninstalling deployment.."
    cfy executions start -d airQ uninstall
    echo "Deleting deployment.."
    cfy deployments delete airQ
    echo "Deleting blueprint.."
    cfy blueprints delete airQ
)
