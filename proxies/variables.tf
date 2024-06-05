variable "defaults" {
}

variable "projects" {
}

variable "default_proxies_config" {
  description = "Default configuration for proxies"
  type = object({
    online       = optional(bool)
    routing_rule = optional(string)
  })
  default = {
    online = true
  }
}

variable "default_npm_proxies_config" {
  description = "Default npm configuration for proxies"
  type = object({
    remove_non_cataloged = optional(bool)
    remove_quarantined   = optional(bool)
  })
  default = {
  }
}

variable "default_docker_config" {
  description = "Default configuration for Docker proxies"
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

variable "default_docker_proxy_config" {
  description = "Default proxy configuration for Docker proxies"
  type = object({
    index_type = string
    index_url  = optional(string)
  })
  default = {
    index_type = "HUB"
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
    strict_content_type_validation = optional(bool)
  })
  default = {
    blob_store_name = "default"
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

variable "default_proxy_config" {
  description = "Default proxy configuration for proxies"
  type = object({
    remote_url       = string
    content_max_age  = optional(number)
    metadata_max_age = optional(number)
  })
  default = {
    remote_url = null
  }
}

variable "default_negative_cache_config" {
  description = "Default negative cache configuration for proxies"
  type = object({
    enabled = optional(bool)
    ttl     = optional(number)
  })
  default = {
  }
}

variable "default_http_client_config" {
  description = "Default negative cache configuration for proxies"
  type = object({
    auto_block = bool
    blocked    = bool
    authentication = optional(object({
      type        = string
      ntlm_domain = optional(string)
      ntlm_host   = optional(string)
      password    = optional(string)
      username    = optional(string)
    }))
    connection = optional(object({
      enable_circular_redirects = optional(bool)
      enable_cookies            = optional(bool)
      retries                   = optional(number)
      timeout                   = optional(number)
      use_trust_store           = optional(bool)
      user_agent_suffix         = optional(string)
    }))
  })
  default = {
    auto_block = true
    blocked    = false
  }
}
