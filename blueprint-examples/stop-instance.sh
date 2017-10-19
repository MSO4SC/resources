#!/bin/bash

curl http://10.38.3.149/api/v3.1/node-instances/$1 -X PATCH \
	--header "Tenant: default_tenant" \
	-u admin:admin \
	-H "Content-Type: application/json" -d '{"status": "deleted", "version":0}'
echo ''
