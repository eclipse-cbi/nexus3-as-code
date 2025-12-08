# for debug
output "npm_proxies" {
  value = local.npm_proxies
}

##############################################
# npm proxies
##############################################

resource "nexus_repository_npm_proxy" "npm-proxies" {
  for_each = {
    for proxy in local.npm_proxies : proxy.name => proxy
  }

  name = each.value.name

  online       = each.value.online
  routing_rule = each.value.routing_rule

  remove_non_cataloged = each.value.remove_non_cataloged
  remove_quarantined   = each.value.remove_quarantined

  proxy {
    remote_url       = each.value.proxy.remote_url
    content_max_age  = each.value.proxy.content_max_age
    metadata_max_age = each.value.proxy.metadata_max_age
  }

  storage {
    blob_store_name                = each.value.storage.blob_store_name
    strict_content_type_validation = each.value.storage.strict_content_type_validation
  }

  http_client {
    blocked    = each.value.http_client.blocked
    auto_block = each.value.http_client.auto_block

    dynamic "authentication" {
      for_each = each.value.http_client.authentication != null ? [each.value.http_client.authentication] : []
      content {
        type        = authentication.value.type
        ntlm_domain = authentication.value.ntlm_domain
        ntlm_host   = authentication.value.ntlm_host
        password    = authentication.value.password
        username    = authentication.value.username
      }
    }
    dynamic "connection" {
      for_each = each.value.http_client.connection != null ? [each.value.http_client.connection] : []
      content {
        enable_circular_redirects = connection.value.enable_circular_redirects
        enable_cookies            = connection.value.enable_cookies
        retries                   = connection.value.retries
        timeout                   = connection.value.timeout
        use_trust_store           = connection.value.use_trust_store
        user_agent_suffix         = connection.value.user_agent_suffix
      }
    }
  }

  dynamic "cleanup" {
    for_each = each.value.cleanup != null ? [each.value.cleanup] : []
    content {
      policy_names = cleanup.value.policy_names
    }
  }

  dynamic "negative_cache" {
    for_each = each.value.negative_cache != null ? [each.value.negative_cache] : []
    content {
      enabled = negative_cache.value.enabled
      ttl     = negative_cache.value.ttl
    }
  }
}
