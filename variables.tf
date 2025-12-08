variable "repo_address" {
  type = string
}

variable "repo_insecure" {
  type = bool
}

variable "repo_env" {
  type = string
}

variable "secretsmanager_address" {
  type = string
}

variable "defaults" {
}

variable "projects" {
  description = <<-EOT
    List of projects with their repositories and proxies configuration.
    
    Structure:
    [
      {
        project_id = "project.name"  # Project identifier (e.g., "ee4j.mail")
        
        repositories = [  # Optional: List of hosted repositories
          {
            type = "maven2" | "docker" | "npm" | "pypi" | "helm"  # Repository type
            env  = ["staging", "releases"]  # Optional: Environment suffixes
            
            # Name customization (optional)
            name                 = "custom-base-name"  # Override base name extraction
            include_type_in_name = true | false        # Include type in name (default: true)
            include_env_in_name  = true | false        # Include env in name (default: true)
            custom_name          = "base-custom-name"  # Base custom name (type/env can still be added)
            
            # Group configuration (optional)
            group_suffix      = "central" | "prod" | ""  # Group suffix (default: "central", empty to remove)
            custom_group_name = "base-group-name"        # Base custom group name (type/suffix can still be added)
            
            # Type-specific configuration (optional)
            storage   = { ... }  # Storage configuration
            cleanup   = { ... }  # Cleanup policies
            component = { ... }  # Component settings
            docker    = { ... }  # Docker-specific settings (for docker type)
            maven     = { ... }  # Maven-specific settings (for maven2 type)
          }
        ]
        
        proxies = [  # Optional: List of proxy repositories
          {
            type = "maven2" | "docker" | "npm" | "pypi" | "helm"  # Proxy type
            # Same customization options as repositories
          }
        ]
        
        groups = [  # Optional: Repository groups configuration
          {
            type = "maven2" | "docker" | "npm" | "pypi"  # Group type
            # Customization options
          }
        ]
      }
    ]
    
    Examples:
    1. Simple repository with type in name:
       { project_id = "ee4j.mail", repositories = [{ type = "maven2", env = ["staging"] }] }
       → Creates: "mail-maven2-staging" repo and "mail-maven2-central" group
    
    2. Repository without type in name:
       { project_id = "ee4j.mail", repositories = [{ type = "maven2", env = ["staging"], include_type_in_name = false }] }
       → Creates: "mail-staging" repo and "mail-central" group
    
    3. Repository without env in name:
       { project_id = "ee4j.mail", repositories = [{ type = "maven2", env = ["staging"], include_env_in_name = false }] }
       → Creates: "mail-maven2" repo
    
    4. Custom base name with type and env:
       { project_id = "ee4j.mail", repositories = [{ type = "maven2", env = ["staging"], custom_name = "myrepo" }] }
       → Creates: "myrepo-maven2-staging" repo (type and env still added)
    
    5. Custom base name without type:
       { project_id = "ee4j.mail", repositories = [{ type = "maven2", env = ["staging"], custom_name = "myrepo", include_type_in_name = false }] }
       → Creates: "myrepo-staging" repo
    
    6. Custom group suffix:
       { project_id = "ee4j.mail", repositories = [{ type = "maven2", env = ["staging"], group_suffix = "prod" }] }
       → Creates: "mail-maven2-staging" repo and "mail-maven2-prod" group
    
    7. No group suffix:
       { project_id = "ee4j.mail", repositories = [{ type = "maven2", env = ["staging"], group_suffix = "" }] }
       → Creates: "mail-maven2-staging" repo and "mail-maven2" group
    
    8. Custom group name with type:
       { project_id = "ee4j.mail", repositories = [{ type = "maven2", custom_group_name = "mygroup" }] }
       → Creates group: "mygroup-maven2-central" (type and suffix still added)
    
    9. Custom group name without type or suffix:
       { project_id = "ee4j.mail", repositories = [{ type = "maven2", custom_group_name = "mygroup", include_type_in_name = false, group_suffix = "" }] }
       → Creates group: "mygroup"
  EOT
}
