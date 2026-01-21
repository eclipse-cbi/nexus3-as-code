# for debug
output "pypi_repositories_group" {
  value = local.pypi_repositories_group
}

##############################################
# Pypi groups
##############################################

resource "nexus_repository_pypi_group" "pypi_repositories_group" {
  for_each = {
    for group in local.pypi_repositories_group : group.final_name => group
  }

  name = each.value.final_name

  group {
    member_names = each.value.custom_members != null ? each.value.custom_members : concat(
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
