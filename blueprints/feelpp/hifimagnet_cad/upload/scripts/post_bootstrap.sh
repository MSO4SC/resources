#!/bin/bash -l

# set -euo pipefail
# set -x

# Custom logs
LOG_FILE=$0.log

echo "bootstrap" >> "${LOG_FILE}"
echo "parameters: $*" >> "${LOG_FILE}"

cat > create_arch.sh <<"EOF"
#! /bin/bash

tar zcvf $1.tgz *.xao *.brep *.med   
EOF

chmod u+x create_arch.sh
