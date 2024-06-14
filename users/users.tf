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

# output "users_projects_calculated" {
#   value = local.calculated_projects
# }

# output "users_projects" {
#   value = local.project_transform
# }

# PRO Feature: error 404 on local instance
resource "nexus_security_user_token" "bot_token" {
  enabled         = true
  protect_content = true
}

resource "nexus_security_role" "role_bot_token" {
  roleid      = "bot-token-role"
  name        = "bot-token-role"
  description = "Allow bots to have permission token"
  privileges  = ["nx-usertoken-current"]
}


resource "nexus_security_user" "bot_user" {
  for_each  = { for project in local.project_transform : project.project_id => project }
  userid    = length(local.project_split[each.key]) > 1 ? "eclipse-${local.project_split[each.key][1]}-bot" : "eclipse-${each.key}-bot"
  firstname = length(local.project_split[each.key]) > 1 ? local.project_split[each.key][0] : each.key
  lastname  = length(local.project_split[each.key]) > 1 ? local.project_split[each.key][1] : ""
  email     = length(local.project_split[each.key]) > 1 ? "${local.project_split[each.key][1]}-bot@eclipse.org" : "${each.key}-bot@eclipse.org"
  password  = random_password.bot_gen_password[each.key].result
  roles     = flatten([each.value.roles_repository, each.value.roles_proxy, "nx-anonymous", "bot-token-role"])
  status    = "active"
  depends_on = [ nexus_security_role.role_bot_token ]
}

data "external" "bot_user_token" {
  for_each  = { for project in local.project_transform : project.project_id => project }

  # https://support.sonatype.com/hc/en-us/articles/213465878-How-to-retrieve-a-user-token-from-Nexus-Repository-using-REST
  program = ["bash", "./users/fetch_user_token.sh"]

#   program = ["bash", "-c", <<EOF
#     set -x
#     eval "$(jq -r '@sh "URL=\(.url) USERNAME=\(.username) PASSWORD=\(.password)"')"

#     RESPONSE=$(curl -u $USERNAME:$PASSWORD -X POST "$URL/api/v2/userTokens/currentUser" -H "Content-Type: application/json" -d '{}')
#     echo $RESPONSE
# EOF
#   ]

    query = {
      url = var.repo_address
      username = nexus_security_user.bot_user[each.key].userid
      password = nexus_security_user.bot_user[each.key].password
    }
}


resource "vault_kv_secret_v2" "bot_token_creds" {
  for_each = {
    for project in var.projects : project.project_id => project
  }

  mount = "cbi"
  name  = "${each.key}/repo3.eclipse.org"

  data_json = jsonencode({
    username = nexus_security_user.bot_user[each.key].userid
    password = nexus_security_user.bot_user[each.key].password
    email    = nexus_security_user.bot_user[each.key].email
    token-username = data.external.bot_user_token[each.key].result["nameCode"]
    token-password = data.external.bot_user_token[each.key].result["passCode"]
  })
}