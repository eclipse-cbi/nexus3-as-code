variable "repo_address" {
  type = string
}

variable "repo_insecure" {
  type = bool
}

variable "secretsmanager_address" {
  type = string
}

variable "secretsmanager_path" {
  type        = string
  description = "Path suffix for secrets in Vault (e.g., 'repo3.eclipse.org')"
  default     = "repo.eclipse.org"
}

variable "defaults" {
}

variable "global_groups" {
  description = "Global repository groups that automatically collect repositories by type and environment"
  type = list(object({
    type                 = string
    custom_name          = optional(string)
    include_type_in_name = optional(bool, false)
    auto_collect = optional(object({
      env  = string
      type = string
    }))
  }))
  default = []
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
            env  = "staging" | "releases" | "snapshots" | ""       # Optional: Environment suffix (single value, not array)
            
            # Name customization (optional)
            name                 = "custom-base-name"  # Override base name extraction
            include_type_in_name = true | false        # Include type in name (default: true)
            include_env_in_name  = true | false        # Include env in name (default: true)
            custom_name          = "base-custom-name"  # Base custom name (type/env can still be added)
            
            # Group configuration (optional)
            group_suffix      = "central" | "prod" | ""  # Group suffix (default: "", empty to remove)
            custom_group_name = "base-group-name"        # Base custom group name (type/suffix can still be added)
            
            # Type-specific configuration (optional)
            storage   = { 
              blob_store_name                = "blobstore-name"  # Default: project blobstore
              strict_content_type_validation = true | false
              write_policy                   = "ALLOW" | "ALLOW_ONCE" | "DENY"
            }
            cleanup   = { 
              policy_names = ["policy1", "policy2"]
            }
            component = { 
              proprietary_components = true | false
            }
            docker    = { 
              force_basic_auth = true | false
              v1_enabled       = true | false
              http_port        = 8080
              https_port       = 8443
            }
            maven     = { 
              version_policy      = "RELEASE" | "SNAPSHOT" | "MIXED"
              layout_policy       = "STRICT" | "PERMISSIVE"
              content_disposition = "INLINE" | "ATTACHMENT"
            }
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
            group_suffix      = "central" | "prod" | ""  # Group suffix (default: "", empty to remove)
            custom_group_name = "base-group-name"        # Base custom group name (type/suffix can still be added)
            
            # Proxy-specific configuration (optional)
            remote_url = "https://..."  # Remote repository URL
            storage    = { 
              blob_store_name                = "blobstore-name"  # Default: project blobstore
              strict_content_type_validation = true | false
            }
            cleanup    = { 
              policy_names = ["policy1", "policy2"]
            }
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
            storage = { 
              blob_store_name                = "blobstore-name"  # Default: project blobstore
              strict_content_type_validation = true | false
            }
          }
        ]
        
        # Blobstore configuration (optional)
        blobstore_soft_quota_limit = 45  # Soft quota limit in GB (default: 45)
        blobstore_soft_quota_type  = "spaceUsedQuota"  # Quota type (default: spaceUsedQuota)
        
        # Archived project flag (optional)
        archived = true | false  # If true, no bot user will be created for this project (default: false)
        
        # Automatic group creation control (optional)
        create_group_auto = true | false  # If true, automatic repository groups will be created (default: false)
        
        # Force token update in Vault (optional)
        force_token_update = true | false  # If true, forces regeneration of tokens in Vault (default: false). Set to true, apply, then set back to false.
      }
    ]
    
    Example for Maven repositories:
    {
      "project_id": "technology.cbi",
      "repositories": [
        {
          "type": "maven2",
          "env": "releases",
          "maven": {
            "version_policy": "RELEASE",
            "layout_policy": "STRICT",
            "content_disposition": "INLINE"
          },
          "storage": {
            "write_policy": "ALLOW"
          }
        },
        {
          "type": "maven2",
          "env": "snapshots",
          "maven": {
            "version_policy": "SNAPSHOT"
          }
        },
        {
          "type": "maven2",
          "env": "staging"
        }
      ]
    }
  EOT
}
