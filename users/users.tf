resource "random_password" "bot_gen_password" {
  for_each = { for project in var.projects : project.project_id => project }

  length  = 16
  special = true
}

locals {
  project_split = {
    for project in var.projects : project.project_id => split(".", project.project_id)
  }
}

resource "vault_kv_secret_v2" "bot_creds" {
  for_each = {
    for project in var.projects : project.project_id => project
  }

  mount = "cbi"
  name  = "${each.key}/repo3.eclipse.org"

  data_json = jsonencode({
    username = length(local.project_split[each.key]) > 1 ? "eclipse-${local.project_split[each.key][1]}-bot" : "eclipse-${each.key}-bot"
    password = random_password.bot_gen_password[each.key].result
    email    = length(local.project_split[each.key]) > 1 ? "${local.project_split[each.key][1]}-bot@eclipse.org" : "${each.key}-bot@eclipse.org"
  })
}

# output "users_projects_calculated" {
#   value = local.calculated_projects
# }

# output "users_projects" {
#   value = local.project_transform
# }

resource "nexus_security_user" "bot_user" {
  for_each  = { for project in local.project_transform : project.project_id => project }
  userid    = vault_kv_secret_v2.bot_creds[each.key].data["username"]
  firstname = length(local.project_split[each.key]) > 1 ? local.project_split[each.key][0] : each.key
  lastname  = length(local.project_split[each.key]) > 1 ? local.project_split[each.key][1] : ""
  email     = vault_kv_secret_v2.bot_creds[each.key].data["email"]
  password  = vault_kv_secret_v2.bot_creds[each.key].data["password"]
  roles     = flatten([each.value.roles_repository, each.value.roles_proxy, "nx-anonymous"])
  status    = "active"
}

# error 404 on local instance
# resource "nexus_security_user_token" "bot_token" {
#   enabled         = true
#   protect_content = true
# }
