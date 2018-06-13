#!/bin/bash -l

# set -euo pipefail
# set -x

# Custom logs
LOG_FILE=$0.log

echo "bootstrap" >> ${LOG_FILE}
echo "parameters: $@" >> ${LOG_FILE}

nargs=$#
echo "nargs: $nargs" >> ${LOG_FILE}
echo "last arg: ${!nargs}" >> ${LOG_FILE}

echo "pwd: ${PWD}"  >> ${LOG_FILE}
echo "ls:\n "  >> ${LOG_FILE}
$(ls -larth)  >> ${LOG_FILE}
