#!/bin/bash -l

# set -euo pipefail
# set -x

# Custom logs
LOG_FILE=$0.log

echo "revert" >> "${LOG_FILE}"
echo "parameters: $*" >> "${LOG_FILE}"

