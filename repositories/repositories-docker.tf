# for debug
output "docker_repositories" {
  value = local.docker_repositories
}

##############################################
# Docker repositories
##############################################

resource "nexus_repository_docker_hosted" "docker_repositories" {
  for_each = {
    for repo in local.docker_repositories : repo.name => repo
  }

  name = each.value.name

  online = each.value.online

  docker {
    force_basic_auth = each.value.docker.force_basic_auth
    v1_enabled       = each.value.docker.v1_enabled
    http_port        = each.value.docker.http_port
    https_port       = each.value.docker.https_port
    # subdomain        = each.value.docker.subdomain  # Pro-only
  }

  storage {
    blob_store_name                = each.value.storage.blob_store_name
    strict_content_type_validation = each.value.storage.strict_content_type_validation
    write_policy                   = each.value.storage.write_policy
  }

  dynamic "cleanup" {
    for_each = each.value.cleanup != null ? [each.value.cleanup] : []
    content {
      policy_names = cleanup.value.policy_names
    }
  }

  dynamic "component" {
    for_each = each.value.component != null ? [each.value.component] : []

    content {
      proprietary_components = component.value.proprietary_components
    }
  }
}
