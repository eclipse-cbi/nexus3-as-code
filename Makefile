# Makefile for GitLab OVHcloud Infrastructure 
.PHONY: help init plan apply destroy validate fmt clean status outputs compile-jsonnet

# Variables
JSONNET_FILE ?= env/terraform.$(NEXUS_ENV).tfvars.jsonnet
TF_VAR_FILE ?= terraform.$(NEXUS_ENV).tfvars.json


help:
	@echo "Available command :"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

check:
	@./check.sh $(TF_VAR_FILE) $(JSONNET_FILE)

init:
	@echo "🚀 Initializing Terraform..."
	terraform init -backend-config=./backend/backend.$(NEXUS_ENV).hcl

select:
	@echo "🔄 Selecting Terraform workspace..."
	@terraform workspace select $(NEXUS_ENV) || terraform workspace new $(NEXUS_ENV)

validate: init
	@echo "✅ Validating configuration..."
	terraform validate

fmt:
	@echo "🎨 Formatting files..."
	terraform fmt -recursive

compile-jsonnet:
	@if [ -f $(JSONNET_FILE) ]; then \
		echo "📦 Compiling $(JSONNET_FILE) to $(TF_VAR_FILE)..."; \
		jsonnet $(JSONNET_FILE) > $(TF_VAR_FILE); \
		echo "✅ Compilation successful"; \
	else \
		echo "⚠️  Jsonnet file $(JSONNET_FILE) not found, using existing $(TF_VAR_FILE)"; \
	fi

plan: check compile-jsonnet validate
	@echo "📋 Planning deployment..."
	terraform plan -var-file=$(TF_VAR_FILE)

apply: check compile-jsonnet validate
	@echo "🚀 Applying Terraform configuration..."
	terraform apply -var-file=$(TF_VAR_FILE)

destroy: check compile-jsonnet
	@echo "💥 Destroying configuration..."
	@echo "⚠️  WARNING: This will destroy ALL configuration!"
	@read -p "Type 'yes' to confirm: " confirm && [ "$$confirm" = "yes" ]
	terraform destroy -var-file=$(TF_VAR_FILE)

refresh: check compile-jsonnet
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
