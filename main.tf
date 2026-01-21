terraform {

  backend "kubernetes" {
    secret_suffix = "state"
    config_path   = "~/.kube/config"
  }

  required_providers {
    nexus = {
      source  = "datadrivers/nexus"
      version = "2.6.0"
    }
  }
}


provider "nexus" {
  insecure = var.repo_insecure # NEXUS_INSECURE_SKIP_VERIFY Default:true
  url      = var.repo_address  # NEXUS_URL Default:http://127.0.0.1:8080
  # username = "admin"           # NEXUS_USERNAME Default:admin
  # password = "XXXXX"        # NEXUS_PASSWORD Default:admin123
  timeout = 10 # NEXUS_TIMEOUT Default:30
}

provider "vault" {
  # environment variables:
  #    - VAULT_ADDR
  #    - VAULT_TOKEN
  #    - VAULT_CACERT
  #    - VAULT_CAPATH
  #    - etc.
  address          = var.secretsmanager_address
  skip_child_token = true
}
