#!/bin/bash

export NEXUS_ENV="${1:-prod}"

if [ -z "$NEXUS_ENV" ]; then
    echo "Usage: source .env.sh [environment]"
    echo "Example: source .env.sh prod"
    return 1
fi
echo "Loading environment: $NEXUS_ENV"

vaultctl login 

echo "Exporting Vault secrets and user credentials..."
eval $(vaultctl export-vault)
eval $(vaultctl export-users-cbi NEXUS_USERNAME:NEXUS_USERNAME_$NEXUS_ENV NEXUS_PASSWORD:NEXUS_PASSWORD_$NEXUS_ENV PASSWORD_STORE_DIR)
