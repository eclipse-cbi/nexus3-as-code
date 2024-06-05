# for debug
output "maven_repositories_group" {
  value = local.maven_repositories_group
}

##############################################
# Maven groups
##############################################

resource "nexus_repository_maven_group" "maven_repositories_group" {
  for_each = {
    for group in local.maven_repositories_group : "${group.project_id}-${group.type}" => group
  }

  name = "${each.value.name}-${each.value.type}-central"

  group {
    member_names = concat(
      each.value.group,
      each.value.proxy_group
    )
  }

  online = each.value.online

  storage {
    blob_store_name                = each.value.storage.blob_store_name
    strict_content_type_validation = each.value.storage.strict_content_type_validation
  }
}
