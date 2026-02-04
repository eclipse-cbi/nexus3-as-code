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
    members = optional(list(string))
  }))
  default = []
}

variable "projects" {
}

variable "project_blobstores" {
  description = "Map of project_id to blobstore name"
  type        = map(string)
  default     = {}
}

variable "default_repository_config" {
  description = "Default configuration for repositories"
  type = object({
    online = bool
  })
  default = {
    online = true
  }
}

variable "default_docker_config" {
  description = "Default configuration for Docker repositories"
  type = object({
    force_basic_auth = bool
    v1_enabled       = bool
    http_port        = optional(number)
    https_port       = optional(number)
    subdomain        = optional(string)
  })
  default = {
    force_basic_auth = false
    v1_enabled       = false
  }
}

variable "default_storage_config" {
  description = "Default configuration for storage"
  type = object({
    blob_store_name                = string
    strict_content_type_validation = bool
  })
  default = {
    blob_store_name                = "default"
    strict_content_type_validation = true
  }
}

variable "default_maven_config" {
  description = "Default configuration for Maven repositories"
  type = object({
    version_policy      = string
    layout_policy       = string
    content_disposition = optional(string)
  })
  default = {
    version_policy = "MIXED"
    layout_policy  = "STRICT"
  }
}
