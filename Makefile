# Makefile for GitLab OVHcloud Infrastructure 
.PHONY: help init plan apply destroy validate fmt clean status outputs

# Variables

TF_VAR_FILE ?= terraform.$(NEXUS_ENV).tfvars.json

help:
	@echo "Available command :"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

check-vars:
	@if [ ! -f $(TF_VAR_FILE) ]; then \
		echo "❌ File $(TF_VAR_FILE) missing !"; \
		echo "📝 Copy terraform.tfvars.example to $(TF_VAR_FILE) and configure it"; \
		exit 1; \
	else \
		echo "✅ File $(TF_VAR_FILE) found."; \
	fi

init:
	@echo "🚀 Initializing Terraform..."
	terraform init

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
