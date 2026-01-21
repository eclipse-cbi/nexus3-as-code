# Makefile for GitLab OVHcloud Infrastructure 
.PHONY: help init plan apply destroy validate fmt clean status outputs

# Variables
TF_VAR_FILE ?= terraform.$(NEXUS_ENV).tfvars.json


help:
	@echo "Available command :"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

check-vars:
	echo "🔍 Checking prerequisites..."; \
	if command -v vault >/dev/null 2>&1; then \
		if vault token lookup >/dev/null 2>&1; then \
			echo "  ✅ Vault connection successful"; \
		else \
			echo "  ❌ Vault token is invalid or expired"; \
			echo "     💡 Tip: Run 'vault login' or source .env.sh"; \
			exit 1; \
		fi; \
	else \
		echo "  ⚠️  Vault CLI not found (optional)"; \
	fi; \
	errors=0; \
	env_vars="NEXUS_ENV NEXUS_USERNAME NEXUS_PASSWORD"; \
	for var in $$env_vars; do \
		eval value=\$$$$var; \
		if [ -z "$$value" ]; then \
			echo "  ❌ $$var environment variable is not set"; \
			errors=$$((errors + 1)); \
		else \
			if [ "$$var" = "VAULT_ENV" ]; then \
				echo "  ✅ $$var=$$value"; \
			else \
				echo "  ✅ $$var is set"; \
			fi; \
		fi; \
	done; \
	\
	if [ ! -f $(TF_VAR_FILE) ]; then \
		echo "  ❌ Configuration file $(TF_VAR_FILE) not found"; \
		echo "     💡 Tip: Copy terraform.tfvars.example to $(TF_VAR_FILE) and configure it"; \
		errors=$$((errors + 1)); \
	else \
		echo "  ✅ Configuration file $(TF_VAR_FILE) found"; \
	fi; \
	\
	if ! command -v terraform >/dev/null 2>&1; then \
		echo "  ❌ Terraform is not installed or not in PATH"; \
		errors=$$((errors + 1)); \
	else \
		echo "  ✅ Terraform is installed $$(terraform version -json | jq .terraform_version)"; \
	fi; \
	\
	if [ -n "$(NEXUS_ENV)" ] && [ -f ./backend/backend.$(NEXUS_ENV).hcl ]; then \
		echo "  ✅ Backend configuration file found"; \
	elif [ -n "$(NEXUS_ENV)" ]; then \
		echo "  ❌ Backend configuration file ./backend/backend.$(NEXUS_ENV).hcl not found"; \
		errors=$$((errors + 1)); \
	fi; \
	\
	echo ""; \
	if [ $$errors -gt 0 ]; then \
		echo "❌ Prerequisites check failed with $$errors error(s)"; \
		exit 1; \
	else \
		echo "✅ All prerequisites are satisfied"; \
	fi

init:
	@echo "🚀 Initializing Terraform..."
	terraform init -backend-config=./backend/backend.$(NEXUS_ENV).hcl

select:
	@echo "🔄 Selecting Terraform workspace..."
	@terraform workspace select $(NEXUS_ENV) || terraform workspace new $(NEXUS_ENV)

validate: init ## Validate Terraform configuration
	@echo "✅ Validating configuration..."
	terraform validate

fmt:
	@echo "🎨 Formatting files..."
	terraform fmt -recursive

plan: check-vars validate
	@echo "📋 Planning deployment..."
	terraform plan -var-file=$(TF_VAR_FILE)

apply: check-vars validate
	@echo "🚀 Applying Terraform configuration..."
	terraform apply -var-file=$(TF_VAR_FILE)

destroy: check-vars
	@echo "💥 Destroying configuration..."
	@echo "⚠️  WARNING: This will destroy ALL configuration!"
	@read -p "Type 'yes' to confirm: " confirm && [ "$$confirm" = "yes" ]
	terraform destroy -var-file=$(TF_VAR_FILE)

refresh: check-vars
	@echo "🔄 Refreshing Terraform configuration..."
	terraform refresh -var-file=$(TF_VAR_FILE)

outputs:
	@echo "📊 Infrastructure outputs:"
	terraform output

outputs-json:
	@echo "📊 Outputs in JSON:"
	terraform output -json

status:
	@echo "📊 Infrastructure status:"
	terraform show

clean:
	@echo "🧹 Cleaning up..."
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate.backup
