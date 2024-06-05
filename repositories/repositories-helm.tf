# for debug
output "helm_repositories" {
  value = local.helm_repositories
}


##############################################
# helm repositories
##############################################

resource "nexus_repository_helm_hosted" "helm_repositories" {
  for_each = {
    for repo in local.helm_repositories : "${repo.name}-${repo.type}${repo.env != "" ? "-${repo.env}" : ""}" => repo
  }

  name = "${each.value.name}-${each.value.type}${each.value.env != "" ? "-${each.value.env}" : ""}"

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
