variable "defaults" {
  type = object({
    proxies = optional(object({

      docker = optional(object({

        online       = optional(bool)
        routing_rule = optional(string)

        docker = optional(object({
          force_basic_auth = optional(bool)
          v1_enabled       = optional(bool)
          subdomain        = optional(string)
        }))

        docker_proxy = optional(object({
          index_type = optional(string)
        }))

        storage = optional(object({
          blob_store_name                = optional(string)
          strict_content_type_validation = optional(bool)
        }))

        proxy = optional(object({
          remote_url       = optional(string)
          content_max_age  = optional(number)
          metadata_max_age = optional(number)
        }))

        negative_cache = optional(object({
          enabled = optional(bool)
          ttl     = optional(number)
        }))

        http_client = optional(object({
          auto_block = optional(bool)
          blocked    = optional(bool)
          authentication = optional(object({
            type        = optional(string)
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
        }))

        cleanup = optional(object({
          policy_names = optional(list(string))
        }))

      }))
      helm = optional(object({

        online       = optional(bool)
        routing_rule = optional(string)

        storage = optional(object({
          blob_store_name                = optional(string)
          strict_content_type_validation = optional(bool)
        }))

        proxy = optional(object({
          remote_url       = optional(string)
          content_max_age  = optional(number)
          metadata_max_age = optional(number)
        }))

        negative_cache = optional(object({
          enabled = optional(bool)
          ttl     = optional(number)
        }))

        http_client = optional(object({
          auto_block = optional(bool)
          blocked    = optional(bool)
          authentication = optional(object({
            type        = optional(string)
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
        }))

        cleanup = optional(object({
          policy_names = optional(list(string))
        }))

      }))

      maven2 = optional(object({

        online       = optional(bool)
        routing_rule = optional(string)

        maven = optional(object({
          version_policy      = optional(string)
          layout_policy       = optional(string)
          content_disposition = optional(string)
        }))

        storage = optional(object({
          blob_store_name                = optional(string)
          strict_content_type_validation = optional(bool)
        }))

        proxy = optional(object({
          remote_url       = optional(string)
          content_max_age  = optional(number)
          metadata_max_age = optional(number)
        }))

        negative_cache = optional(object({
          enabled = optional(bool)
          ttl     = optional(number)
        }))

        http_client = optional(object({
          auto_block = optional(bool)
          blocked    = optional(bool)
          authentication = optional(object({
            type        = optional(string)
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
        }))

        cleanup = optional(object({
          policy_names = optional(list(string))
        }))

      }))

      npm = optional(object({
        online       = optional(bool)
        routing_rule = optional(string)

        remove_non_cataloged = optional(bool)
        remove_quarantined   = optional(bool)

        storage = optional(object({
          blob_store_name                = optional(string)
          strict_content_type_validation = optional(bool)
        }))

        proxy = optional(object({
          remote_url       = optional(string)
          content_max_age  = optional(number)
          metadata_max_age = optional(number)
        }))

        negative_cache = optional(object({
          enabled = optional(bool)
          ttl     = optional(number)
        }))

        http_client = optional(object({
          auto_block = optional(bool)
          blocked    = optional(bool)
          authentication = optional(object({
            type        = optional(string)
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
        }))

        cleanup = optional(object({
          policy_names = optional(list(string))
        }))

      }))

      pypi = optional(object({

        online       = optional(bool)
        routing_rule = optional(string)

        storage = optional(object({
          blob_store_name                = optional(string)
          strict_content_type_validation = optional(bool)
        }))

        proxy = optional(object({
          remote_url       = optional(string)
          content_max_age  = optional(number)
          metadata_max_age = optional(number)
        }))

        negative_cache = optional(object({
          enabled = optional(bool)
          ttl     = optional(number)
        }))

        http_client = optional(object({
          auto_block = optional(bool)
          blocked    = optional(bool)
          authentication = optional(object({
            type        = optional(string)
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
        }))

        cleanup = optional(object({
          policy_names = optional(list(string))
        }))

      }))

    }))

    repositories = optional(object({

      docker = optional(object({

        online = optional(bool)

        docker = optional(object({
          force_basic_auth = optional(bool)
          v1_enabled       = optional(bool)
          subdomain        = optional(string)
        }))

        storage = optional(object({
          blob_store_name                = optional(string)
          strict_content_type_validation = optional(bool)
          write_policy                   = optional(string)
        }))

        cleanup = optional(object({
          policy_names = optional(list(string))
        }))

        component = optional(object({
          proprietary_components = optional(bool)
        }))

      }))
      helm = optional(object({

        online = optional(bool)

        storage = optional(object({
          blob_store_name                = optional(string)
          strict_content_type_validation = optional(bool)
          write_policy                   = optional(string)
        }))

        cleanup = optional(object({
          policy_names = optional(list(string))
        }))

        component = optional(object({
          proprietary_components = optional(bool)
        }))

      }))

      maven2 = optional(object({

        online = optional(bool)

        maven = optional(object({
          version_policy      = optional(string)
          layout_policy       = optional(string)
          content_disposition = optional(string)
        }))

        storage = optional(object({
          blob_store_name                = optional(string)
          strict_content_type_validation = optional(bool)
          write_policy                   = optional(string)
        }))

        cleanup = optional(object({
          policy_names = optional(list(string))
        }))

        component = optional(object({
          proprietary_components = optional(bool)
        }))
      }))

      npm = optional(object({
        online = optional(bool)

        storage = optional(object({
          blob_store_name                = optional(string)
          strict_content_type_validation = optional(bool)
          write_policy                   = optional(string)
        }))


        cleanup = optional(object({
          policy_names = optional(list(string))
        }))

        component = optional(object({
          proprietary_components = optional(bool)
        }))

      }))

      pypi = optional(object({

        online = optional(bool)

        storage = optional(object({
          blob_store_name                = optional(string)
          strict_content_type_validation = optional(bool)
          write_policy                   = optional(string)
        }))

        cleanup = optional(object({
          policy_names = optional(list(string))
        }))

        component = optional(object({
          proprietary_components = optional(bool)
        }))
      }))

    }))

    groups = optional(object({

      docker = optional(object({

        online = optional(bool)

        docker = optional(object({
          force_basic_auth = optional(bool)
          http_port        = optional(string)
          https_port       = optional(string)
          v1_enabled       = optional(bool)
          subdomain        = optional(string)
        }))

        storage = optional(object({
          blob_store_name                = optional(string)
          strict_content_type_validation = optional(bool)
        }))

      }))

      maven2 = optional(object({

        online = optional(bool)

        storage = optional(object({
          blob_store_name                = optional(string)
          strict_content_type_validation = optional(bool)
        }))

      }))

      npm = optional(object({
        online = optional(bool)

        storage = optional(object({
          blob_store_name                = optional(string)
          strict_content_type_validation = optional(bool)
        }))

      }))

      pypi = optional(object({

        online = optional(bool)

        storage = optional(object({
          blob_store_name                = optional(string)
          strict_content_type_validation = optional(bool)
        }))
      }))

    }))
  })
}


variable "projects" {
  type = list(object({
    project_id = string
    proxies = optional(list(object({
      name = optional(string)
      type = string

      online       = optional(bool)
      routing_rule = optional(string)

      remove_non_cataloged = optional(bool)
      remove_quarantined   = optional(bool)

      docker = optional(object({
        force_basic_auth = optional(bool)
        v1_enabled       = optional(bool)
        subdomain        = optional(string)
      }))

      docker_proxy = optional(object({
        index_type = optional(string)
      }))

      maven = optional(object({
        version_policy      = string
        layout_policy       = string
        content_disposition = optional(string)
      }))

      storage = optional(object({
        blob_store_name                = optional(string)
        strict_content_type_validation = optional(bool)
      }))

      proxy = optional(object({
        remote_url       = optional(string)
        content_max_age  = optional(number)
        metadata_max_age = optional(number)
      }))

      negative_cache = optional(object({
        enabled = optional(bool)
        ttl     = optional(number)
      }))

      http_client = optional(object({
        auto_block = optional(bool)
        blocked    = optional(bool)
        authentication = optional(object({
          type        = optional(string)
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
      }))

      cleanup = optional(object({
        policy_names = optional(list(string))
      }))

    })))
    repositories = optional(list(object({
      name = optional(string)
      type = optional(string)
      env  = optional(list(string))

      docker = optional(object({
        force_basic_auth = optional(bool)
        v1_enabled       = optional(bool)
        subdomain        = optional(string)
      }))

      docker_proxy = optional(object({
        index_type = optional(string)
      }))

      maven = optional(object({
        version_policy      = optional(string)
        layout_policy       = optional(string)
        content_disposition = optional(string)
      }))

      storage = optional(object({
        blob_store_name                = optional(string)
        strict_content_type_validation = optional(bool)
      }))

      cleanup = optional(object({
        policy_names = optional(list(string))
      }))

      component = optional(object({
        proprietary_components = optional(bool)
      }))

    })))
  }))
}

