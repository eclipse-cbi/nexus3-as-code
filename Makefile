# Makefile for GitLab OVHcloud Infrastructure 
.PHONY: help init plan apply destroy validate fmt clean status outputs compile-jsonnet

# Variables
JSONNET_FILE ?= env/terraform.$(NEXUS_ENV).tfvars.jsonnet
TF_VAR_FILE ?= terraform.$(NEXUS_ENV).tfvars.json
TF_PARALLELISM ?= 30

help: ## Display this help message
	@echo "Available command :"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

check: ## Check prerequisites and environment
	@./check.sh $(TF_VAR_FILE) $(JSONNET_FILE)

init: ## Initialize Terraform backend
	@echo "🚀 Initializing Terraform..."
	terraform init -backend-config=./backend/backend.$(NEXUS_ENV).hcl

select: ## Select or create Terraform workspace
	@echo "🔄 Selecting Terraform workspace..."
	@terraform workspace select $(NEXUS_ENV) || terraform workspace new $(NEXUS_ENV)

validate: init ## Validate Terraform configuration
	@echo "✅ Validating configuration..."
	terraform validate

fmt: ## Format Terraform files
	@echo "🎨 Formatting files..."
	terraform fmt -recursive

compile-jsonnet: ## Compile Jsonnet files to JSON
	@if [ -f $(JSONNET_FILE) ]; then \
		echo "📦 Compiling $(JSONNET_FILE) to $(TF_VAR_FILE)..."; \
		jsonnet $(JSONNET_FILE) > $(TF_VAR_FILE); \
		echo "✅ Compilation successful"; \
	else \
		echo "⚠️  Jsonnet file $(JSONNET_FILE) not found, using existing $(TF_VAR_FILE)"; \
	fi

plan: check compile-jsonnet validate ## Plan Terraform changes
	@echo "📋 Planning deployment..."
	terraform plan -var-file=$(TF_VAR_FILE) -parallelism=$(TF_PARALLELISM)

apply: check compile-jsonnet validate ## Apply Terraform configuration
	@echo "🚀 Applying Terraform configuration..."
	terraform apply -var-file=$(TF_VAR_FILE)  -parallelism=$(TF_PARALLELISM)

destroy: check compile-jsonnet ## Destroy all Terraform resources (with confirmation)
	@echo "💥 Destroying configuration..."
	@echo "⚠️  WARNING: This will destroy ALL configuration!"
	@read -p "Type 'yes' to confirm: " confirm && [ "$$confirm" = "yes" ]
	terraform destroy -var-file=$(TF_VAR_FILE)  -parallelism=$(TF_PARALLELISM)

refresh: check compile-jsonnet ## Refresh Terraform state
	@echo "🔄 Refreshing Terraform configuration..."
	terraform refresh -var-file=$(TF_VAR_FILE)  -parallelism=$(TF_PARALLELISM)

outputs: ## Display Terraform outputs
	@echo "📊 Infrastructure outputs:"
	terraform output

outputs-json: ## Display Terraform outputs in JSON format
	@echo "📊 Outputs in JSON:"
	terraform output -json

status: ## Show current Terraform state
	@echo "📊 Infrastructure status:"
	terraform show

clean: ## Clean Terraform files and state
	@echo "🧹 Cleaning up..."
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate.backup
