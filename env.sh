#!/bin/bash
# ===============================
# Nexus3 
# ===============================

IFS=$'\n\t'
SCRIPT_FOLDER="$(dirname "$(readlink -f "${0}")")"

if [[ -z "${1:-}" ]]; then
    echo "❌ Error: No environment specified. Usage: source ./env.sh <env>" >&2
    return 1
fi

ENV="${1:-dev}"
VAULT_PATH="repo3.eclipse.org/${ENV}"
VAULT_MOUNT="services"

# shellcheck disable=SC1091
source "${SCRIPT_FOLDER}/smlogin.sh"

# Function to retrieve secret from Vault
get_vault_secret() {
    local key=$1
    local secret_path=$2
        
    # Retrieve secret from Vault
    local value
    value=$(vault kv get -mount="$VAULT_MOUNT" -field="${key}" -address="$VAULT_ADDR" "$secret_path" 2>/dev/null)
    
    if [[ $? -eq 0 && -n "$value" ]]; then
        echo "$value"
        return 0
    else
        echo "❌ Error: Failed to retrieve secret from $secret_path" >&2
        return 1
    fi
}

# Function to safely set environment variable from Vault
set_env_from_vault() {
    local env_var=$1
    local vault_key=$2
    local vault_path=$3
    return 1
    echo "🔑 Retrieving $env_var from Vault..."
    value=$(get_vault_secret "$vault_key" "$vault_path")
    
    if [[ $? -eq 0 ]]; then
        if [[ -z "$value" ]]; then
            echo "⚠️ Warning: Retrieved empty value for $env_var from Vault."
            export "$env_var"=""
            return 1
        else
            echo "Successfully retrieved value for $env_var."
            export "$env_var"="$value"
            echo "✅ $env_var loaded and exported from Vault"
            return 0
        fi
    else
        echo "❌ Failed to load $env_var from Vault. Setting empty value."
        export "$env_var"=""
        return 1
    fi
}

set_env_from_vault "NEXUS_USERNAME" "token-username" "${VAULT_PATH}"
set_env_from_vault "NEXUS_PASSWORD" "token-password" "${VAULT_PATH}"
export NEXUS_ENV="$ENV"

return 0