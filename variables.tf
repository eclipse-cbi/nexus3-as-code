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
            
            # Name customization (optional)
            name                 = "custom-base-name"  # Override base name extraction
            include_type_in_name = true | false        # Include type in name (default: true)
            custom_name          = "base-custom-name"  # Base custom name (type added, always ends with "-proxy")
            
            # Group configuration (optional)
            group_suffix      = "central" | "prod" | ""  # Group suffix (default: "central", empty to remove)
            custom_group_name = "base-group-name"        # Base custom group name (type/suffix can still be added)
            
            # Proxy-specific configuration (optional)
            remote_url = "https://..."  # Remote repository URL
            storage    = { ... }         # Storage configuration
            cleanup    = { ... }         # Cleanup policies
          }
        ]
        
        groups = [  # Optional: Custom repository groups with explicit members
          {
            type = "maven2" | "docker" | "npm" | "pypi"  # Group type
            
            # Name customization (optional)
            name                 = "custom-base-name"     # Override base name extraction
            include_type_in_name = true | false           # Include type in name (default: false for custom groups)
            custom_name          = "base-custom-name"     # Base custom name (type/suffix can still be added)
            group_suffix         = "" | "suffix"          # Group suffix (default: empty for custom groups)
            custom_group_name    = "base-group-name"      # Base custom group name
            
            # Member repositories (required for custom groups)
            members = ["repo1-maven2-staging", "repo2-maven2-staging", ...]  # List of repository names to include
            
            # Group-specific configuration (optional)
            online  = true | false  # Online status (default: true)
            storage = { ... }       # Storage configuration
          }
        ]
      }
    ]    
  EOT
}
