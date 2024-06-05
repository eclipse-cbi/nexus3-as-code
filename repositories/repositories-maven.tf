# for debug
output "maven_repositories" {
  value = local.maven_repositories
}


##############################################
# Maven repositories
##############################################

resource "nexus_repository_maven_hosted" "maven_repositories" {
  for_each = {
    for repo in local.maven_repositories : "${repo.name}-${repo.type}${repo.env != "" ? "-${repo.env}" : ""}" => repo
  }

  name = "${each.value.name}-${each.value.type}${each.value.env != "" ? "-${each.value.env}" : ""}"

  online = each.value.online

  maven {
    version_policy      = each.value.maven.version_policy
    layout_policy       = each.value.maven.layout_policy
    content_disposition = each.value.maven.content_disposition
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
