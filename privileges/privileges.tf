resource "nexus_privilege_repository_view" "privilege_repo" {

  for_each = {
    for repo in local.repositories : "${repo.name}-${repo.type}${repo.env != "" ? "-${repo.env}" : ""}" => repo
  }

  name = "${each.value.name}-${each.value.type}${each.value.env != "" ? "-${each.value.env}" : ""}-perm"

  actions    = ["ADD", "READ", "DELETE", "BROWSE", "EDIT"]
  repository = "${each.value.name}-${each.value.type}${each.value.env != "" ? "-${each.value.env}" : ""}"
  format     = each.value.type
}

resource "nexus_privilege_repository_view" "privilege_proxies" {

  for_each = {
    for proxy in local.proxies : "${proxy.name}-${proxy.type}-proxy" => proxy
  }

  name = "${each.value.name}-${each.value.type}-proxy-perm"

  actions    = ["ADD", "READ", "DELETE", "BROWSE", "EDIT"]
  repository = "${each.value.name}-${each.value.type}-proxy"
  format     = each.value.type
}
