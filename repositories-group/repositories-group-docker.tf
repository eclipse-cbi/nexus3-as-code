# for debug
output "docker_repositories_group" {
  value = local.docker_repositories_group
}

##############################################
# Docker groups
##############################################

resource "nexus_repository_docker_group" "docker_repositories_group" {
  for_each = {
    for group in local.docker_repositories_group : "${group.project_id}.${group.type}" => group
  }

  name = each.value.final_name

  group {
    member_names = concat(
      each.value.group,
      each.value.proxy_group
    )
  }

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
  }
}
