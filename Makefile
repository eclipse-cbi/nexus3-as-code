# Makefile for GitLab OVHcloud Infrastructure 
.PHONY: help init plan apply destroy validate fmt clean status outputs compile-jsonnet

# Variables
JSONNET_FILE ?= env/terraform.$(NEXUS_ENV).tfvars.jsonnet
TF_VAR_FILE ?= terraform.$(NEXUS_ENV).tfvars.json
TF_PARALLELISM ?= 20

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

plan-project: check compile-jsonnet validate ## Plan changes for a specific project (usage: make plan-project PROJECT=tm4e)
	@if [ -z "$(PROJECT)" ]; then \
		echo "❌ Error: PROJECT is required. Usage: make plan-project PROJECT=tm4e"; \
		exit 1; \
	fi
	@echo "📋 Planning deployment for project: $(PROJECT)..."
	@terraform plan -var-file=$(TF_VAR_FILE) -parallelism=$(TF_PARALLELISM) \
		-target='module.blobstores.nexus_blobstore_file.project_blobstore["$(PROJECT)"]' \
		-target='module.users.vault_kv_secret_v2.bot_secret["$(PROJECT)"]' \
		-target='module.users.nexus_security_user.bot["$(PROJECT)"]' \
		-target='module.roles.nexus_security_role.role_project_repository["$(PROJECT)"]' \
		-target='module.roles.nexus_security_role.role_project_proxy["$(PROJECT)"]' \
		-target='module.repositories.nexus_repository_apt_hosted.apt_hosted["$(PROJECT)"]' \
		-target='module.repositories.nexus_repository_docker_hosted.docker_hosted["$(PROJECT)"]' \
		-target='module.repositories.nexus_repository_helm_hosted.helm_hosted["$(PROJECT)"]' \
		-target='module.repositories.nexus_repository_maven_hosted.maven_hosted["$(PROJECT)"]' \
		-target='module.repositories.nexus_repository_npm_hosted.npm_hosted["$(PROJECT)"]' \
		-target='module.repositories.nexus_repository_pypi_hosted.pypi_hosted["$(PROJECT)"]' \
		-target='module.repositories.nexus_repository_raw_hosted.raw_hosted["$(PROJECT)"]' \
		-target='module.proxies.nexus_repository_apt_proxy.apt_proxy["$(PROJECT)"]' \
		-target='module.proxies.nexus_repository_docker_proxy.docker_proxy["$(PROJECT)"]' \
		-target='module.proxies.nexus_repository_helm_proxy.helm_proxy["$(PROJECT)"]' \
		-target='module.proxies.nexus_repository_maven_proxy.maven_proxy["$(PROJECT)"]' \
		-target='module.proxies.nexus_repository_npm_proxy.npm_proxy["$(PROJECT)"]' \
		-target='module.proxies.nexus_repository_pypi_proxy.pypi_proxy["$(PROJECT)"]' \
		-target='module.proxies.nexus_repository_raw_proxy.raw_proxy["$(PROJECT)"]' \
		-target='module.repositories-group.nexus_repository_docker_group.docker_repositories_group["$(PROJECT)"]' \
		-target='module.repositories-group.nexus_repository_maven_group.maven_repositories_group["$(PROJECT)"]' \
		-target='module.repositories-group.nexus_repository_npm_group.npm_repositories_group["$(PROJECT)"]' \
		-target='module.repositories-group.nexus_repository_pypi_group.pypi_repositories_group["$(PROJECT)"]' \
		-target='module.repositories-group.nexus_repository_raw_group.raw_repositories_group["$(PROJECT)"]'

apply-project: check compile-jsonnet validate ## Apply changes for a specific project (usage: make apply-project PROJECT=tm4e)
	@if [ -z "$(PROJECT)" ]; then \
		echo "❌ Error: PROJECT is required. Usage: make apply-project PROJECT=tm4e"; \
		exit 1; \
	fi
	@echo "🚀 Applying Terraform configuration for project: $(PROJECT)..."
	@terraform apply -var-file=$(TF_VAR_FILE) -parallelism=$(TF_PARALLELISM) \
		-target='module.blobstores.nexus_blobstore_file.project_blobstore["$(PROJECT)"]' \
		-target='module.users.vault_kv_secret_v2.bot_secret["$(PROJECT)"]' \
		-target='module.users.nexus_security_user.bot["$(PROJECT)"]' \
		-target='module.roles.nexus_security_role.role_project_repository["$(PROJECT)"]' \
		-target='module.roles.nexus_security_role.role_project_proxy["$(PROJECT)"]' \
		-target='module.repositories.nexus_repository_apt_hosted.apt_hosted["$(PROJECT)"]' \
		-target='module.repositories.nexus_repository_docker_hosted.docker_hosted["$(PROJECT)"]' \
		-target='module.repositories.nexus_repository_helm_hosted.helm_hosted["$(PROJECT)"]' \
		-target='module.repositories.nexus_repository_maven_hosted.maven_hosted["$(PROJECT)"]' \
		-target='module.repositories.nexus_repository_npm_hosted.npm_hosted["$(PROJECT)"]' \
		-target='module.repositories.nexus_repository_pypi_hosted.pypi_hosted["$(PROJECT)"]' \
		-target='module.repositories.nexus_repository_raw_hosted.raw_hosted["$(PROJECT)"]' \
		-target='module.proxies.nexus_repository_apt_proxy.apt_proxy["$(PROJECT)"]' \
		-target='module.proxies.nexus_repository_docker_proxy.docker_proxy["$(PROJECT)"]' \
		-target='module.proxies.nexus_repository_helm_proxy.helm_proxy["$(PROJECT)"]' \
		-target='module.proxies.nexus_repository_maven_proxy.maven_proxy["$(PROJECT)"]' \
		-target='module.proxies.nexus_repository_npm_proxy.npm_proxy["$(PROJECT)"]' \
		-target='module.proxies.nexus_repository_pypi_proxy.pypi_proxy["$(PROJECT)"]' \
		-target='module.proxies.nexus_repository_raw_proxy.raw_proxy["$(PROJECT)"]' \
		-target='module.repositories-group.nexus_repository_docker_group.docker_repositories_group["$(PROJECT)"]' \
		-target='module.repositories-group.nexus_repository_maven_group.maven_repositories_group["$(PROJECT)"]' \
		-target='module.repositories-group.nexus_repository_npm_group.npm_repositories_group["$(PROJECT)"]' \
		-target='module.repositories-group.nexus_repository_pypi_group.pypi_repositories_group["$(PROJECT)"]' \
		-target='module.repositories-group.nexus_repository_raw_group.raw_repositories_group["$(PROJECT)"]'

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
