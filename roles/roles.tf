resource "nexus_security_role" "role_project_repository" {
  for_each = {
    for project in local.project_transform : project.short_code => project
  }

  roleid      = "${each.key}-repository-admin"
  name        = "${each.key}-repository-admin"
  description = "Project ${each.key} admin repositories role"
  privileges  = each.value.repositories_roles
}

resource "nexus_security_role" "role_project_proxy" {
  for_each = {
    for project in local.project_transform : project.short_code => project
  }

  roleid      = "${each.key}-proxy-admin"
  name        = "${each.key}-proxy-admin"
  description = "Project ${each.key} admin proxies role"
  privileges  = each.value.proxies_roles
}
