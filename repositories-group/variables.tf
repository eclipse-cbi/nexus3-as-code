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

