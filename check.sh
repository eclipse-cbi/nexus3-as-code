#!/usr/bin/env bash
# Prerequisites check script for Nexus Terraform deployment

set -e

# Variables from environment or arguments
TF_VAR_FILE="${1:-terraform.${NEXUS_ENV}.tfvars.json}"
JSONNET_FILE="${2:-env/terraform.${NEXUS_ENV}.tfvars.jsonnet}"

echo "🔍 Checking prerequisites..."

# Check Vault connection
if command -v vault >/dev/null 2>&1; then
	if vault token lookup >/dev/null 2>&1; then
		echo "  ✅ Vault connection successful"
	else
		echo "  ❌ Vault token is invalid or expired"
		echo "     Run 'source .env.sh'"
		exit 1
	fi
else
	echo "  ⚠️  Vault CLI not found (optional)"
fi

# Check environment variables
errors=0
env_vars="NEXUS_ENV NEXUS_USERNAME NEXUS_PASSWORD"
for var in $env_vars; do
	eval value=\$$var
	if [ -z "$value" ]; then
		echo "  ❌ $var environment variable is not set"
		errors=$((errors + 1))
	else
		if [ "$var" = "VAULT_ENV" ]; then
			echo "  ✅ $var=$value"
		else
			echo "  ✅ $var is set"
		fi
	fi
done

# Check configuration file
if [ ! -f "$TF_VAR_FILE" ]; then
	echo "  ❌ Configuration file $TF_VAR_FILE not found"
	echo "     💡 Tip: Copy terraform.tfvars.example to $TF_VAR_FILE and configure it"
	errors=$((errors + 1))
else
	echo "  ✅ Configuration file $TF_VAR_FILE found"
fi

# Check Nexus authentication
if [ -n "$NEXUS_USERNAME" ] && [ -n "$NEXUS_PASSWORD" ]; then
	if command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
		if [ -f "$TF_VAR_FILE" ]; then
			NEXUS_URL=$(jq -r '.repo_address // empty' "$TF_VAR_FILE")
			if [ -z "$NEXUS_URL" ]; then
				NEXUS_URL="${NEXUS_URL:-http://127.0.0.1:8080}"
			fi
			
			echo "  🔐 Testing Nexus authentication at $NEXUS_URL..."
			HTTP_CODE=$(curl -I -s -o /dev/null -w "%{http_code}" \
				-u "$NEXUS_USERNAME:$NEXUS_PASSWORD" \
				"$NEXUS_URL/service/rest/v1/repositories" 2>/dev/null || echo "000")
			
			if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "204" ]; then
				echo "  ✅ Nexus authentication successful (HTTP $HTTP_CODE)"
			else
				echo "  ❌ Nexus authentication failed (HTTP $HTTP_CODE)"
				echo "     Check your NEXUS_USERNAME and NEXUS_PASSWORD"
				errors=$((errors + 1))
			fi
		fi
	else
		echo "  ⚠️  curl or jq not found, skipping Nexus authentication test"
	fi
fi

# Check Jsonnet
if ! command -v jsonnet >/dev/null 2>&1; then
	echo "  ⚠️  Jsonnet is not installed (will use pre-compiled JSON)"
else
	echo "  ✅ Jsonnet is installed"
	if [ -f "$JSONNET_FILE" ]; then
		echo "  ✅ Jsonnet source file $JSONNET_FILE found"
	fi
fi

# Check Terraform
if ! command -v terraform >/dev/null 2>&1; then
	echo "  ❌ Terraform is not installed or not in PATH"
	errors=$((errors + 1))
else
	echo "  ✅ Terraform is installed $(terraform version -json | jq -r .terraform_version)"
fi

# Check backend configuration
if [ -n "$NEXUS_ENV" ] && [ -f "./backend/backend.${NEXUS_ENV}.hcl" ]; then
	echo "  ✅ Backend configuration file found"
elif [ -n "$NEXUS_ENV" ]; then
	echo "  ❌ Backend configuration file ./backend/backend.${NEXUS_ENV}.hcl not found"
	errors=$((errors + 1))
fi

echo ""
if [ $errors -gt 0 ]; then
	echo "❌ Prerequisites check failed with $errors error(s)"
	exit 1
else
	echo "✅ All prerequisites are satisfied"
fi
