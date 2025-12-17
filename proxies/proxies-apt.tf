# for debug
output "apt_proxies" {
  value = local.apt_proxies
}

##############################################
# apt proxies
##############################################

resource "nexus_repository_apt_proxy" "apt-proxies" {
  for_each = {
    for proxy in local.apt_proxies : proxy.name => proxy
  }

  name   = each.value.name
  online = each.value.online

  distribution = each.value.apt.distribution
  flat         = each.value.apt.flat

  proxy {
    remote_url       = each.value.proxy.remote_url
    content_max_age  = each.value.proxy.content_max_age
    metadata_max_age = each.value.proxy.metadata_max_age
  }

  negative_cache {
    enabled = each.value.negative_cache.enabled
    ttl     = each.value.negative_cache.ttl
  }

  http_client {
    blocked    = each.value.http_client.blocked
    auto_block = each.value.http_client.auto_block

    dynamic "connection" {
      for_each = try(each.value.http_client.connection, null) != null ? [each.value.http_client.connection] : []
      content {
        retries                 = try(connection.value.retries, null)
        user_agent_suffix       = try(connection.value.user_agent_suffix, null)
        timeout                 = try(connection.value.timeout, null)
        enable_circular_redirects = try(connection.value.enable_circular_redirects, null)
        enable_cookies          = try(connection.value.enable_cookies, null)
        use_trust_store         = try(connection.value.use_trust_store, null)
      }
    }

    dynamic "authentication" {
      for_each = try(each.value.http_client.authentication, null) != null ? [each.value.http_client.authentication] : []
      content {
        type        = authentication.value.type
        username    = try(authentication.value.username, null)
        password    = try(authentication.value.password, null)
        ntlm_host   = try(authentication.value.ntlm_host, null)
        ntlm_domain = try(authentication.value.ntlm_domain, null)
      }
    }
  }

  storage {
    blob_store_name                = each.value.storage.blob_store_name
    strict_content_type_validation = each.value.storage.strict_content_type_validation
  }

  cleanup {
    policy_names = each.value.cleanup.policy_names
  }
}
