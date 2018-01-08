#!/bin/bash

## execute as ./force-cancel.sh [ADMIN PASSWORD] [EXEC-ID]

curl http://193.144.35.131/executions/$2 -X PATCH \
	--header "Tenant: default_tenant" \
	-u admin:$1 \
	-H "Content-Type: application/json" -d '{"status": "cancelled"}'
echo ''
