resource "nexus_privilege_repository_view" "privilege_repo" {

  for_each = {
    for repo in local.repositories : repo.name => repo
  }

  name = "${each.value.name}-perm"

  actions    = ["ADD", "READ", "DELETE", "BROWSE", "EDIT"]
  repository = each.value.name
  format     = each.value.type
}

resource "nexus_privilege_repository_view" "privilege_proxies" {

  for_each = {
    for proxy in local.proxies : proxy.name => proxy
  }

  name = "${each.value.name}-perm"

  actions    = ["ADD", "READ", "DELETE", "BROWSE", "EDIT"]
  repository = each.value.name
  format     = each.value.type
}
