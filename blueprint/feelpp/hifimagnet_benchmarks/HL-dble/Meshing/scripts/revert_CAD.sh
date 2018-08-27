#!/bin/bash -l

# set -euo pipefail
# set -x

# Custom logs
LOG_FILE=$0.log

echo "revert" >> ${LOG_FILE}
echo "parameters: $@" >> ${LOG_FILE}

nargs=$#
echo "nargs: $nargs" >> ${LOG_FILE}
echo "last arg: ${!nargs}" >> ${LOG_FILE}
