#!/bin/bash

curl http://10.38.3.74/executions/$1 -X PATCH \
	--header "Tenant: default_tenant" \
	-u admin:admin \
	-H "Content-Type: application/json" -d '{"status": "cancelled"}'
echo ''
