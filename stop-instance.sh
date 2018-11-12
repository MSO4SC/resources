#!/bin/bash

## execute as ./force-cancel.sh [ADMIN PASSWORD] [INST-ID]

curl http://193.144.35.131/api/v3.1/node-instances/$2 -X PATCH \
	--header "Tenant: default_tenant" \
	-u admin:$1 \
	-H "Content-Type: application/json" -d '{"status": "deleted", "version":0}'
echo ''
