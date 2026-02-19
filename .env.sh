#!/bin/bash

vaultctl login 

echo "Exporting Vault secrets and user credentials..."
eval $(vaultctl export-vault)
eval $(vaultctl export-users-cbi NEXUS_USERNAME NEXUS_PASSWORD PASSWORD_STORE_DIR)
export NEXUS_ENV="prod"