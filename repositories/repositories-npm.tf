# for debug
output "npm_repositories" {
  value = local.npm_repositories
}


##############################################
# npm repositories
##############################################

resource "nexus_repository_npm_hosted" "npm_repositories" {
  for_each = {
    for repo in local.npm_repositories : repo.name => repo
  }

  name = each.value.name

  online = each.value.online

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
