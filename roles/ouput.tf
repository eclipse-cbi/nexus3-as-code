# for debug purpose
output "calculated_repositories" {
  value = local.calculated_repositories
}

output "project_transform" {
  value = local.project_transform
}

output "all_roles" {
  description = "Map of all created roles for dependency tracking"
  value = {
    for k, v in merge(
      nexus_security_role.role_project_repository,
      nexus_security_role.role_project_proxy
    ) : k => {
      id     = v.id
      roleid = v.roleid
    }
  }
}
