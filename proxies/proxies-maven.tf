# for debug
output "maven_proxies" {
  value = local.maven_proxies
}

##############################################
# maven proxies
##############################################

resource "nexus_repository_maven_proxy" "maven-proxies" {
  for_each = {
    for proxy in local.maven_proxies : "${proxy.name}-${proxy.type}-proxy" => proxy
  }

  name = "${each.value.name}-${each.value.type}-proxy"

  online       = each.value.online
  routing_rule = each.value.routing_rule

  maven {
    version_policy      = each.value.maven.version_policy
    layout_policy       = each.value.maven.layout_policy
    content_disposition = each.value.maven.content_disposition
  }

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
