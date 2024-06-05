variable "defaults" {
}

variable "projects" {
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

variable "default_cleanup_config" {
  description = "Default cleanup configuration for repositories"
  type = object({
    policy_names = optional(list(string))
  })
  default = {
    policy_names = [""]
  }
}

variable "default_component_config" {
  description = "Default component configuration for repositories"
  type = object({
    proprietary_components = bool
  })
  default = {
    proprietary_components = true
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

variable "default_storage_config" {
  description = "Default configuration for storage"
  type = object({
    blob_store_name                = string
    strict_content_type_validation = bool
    write_policy                   = optional(string)
  })
  default = {
    blob_store_name                = "default"
    strict_content_type_validation = true
    # write_policy                   = "ALLOW" # default value
  }
}

