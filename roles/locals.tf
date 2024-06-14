locals {
  calculated_repositories = [
    for project in var.projects : {
      project_id = project.project_id
      short_code = length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : ""
      repositories = [
        for repo in try(project.repositories, []) : {
          name = coalesce(try(repo.name, null), length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : "")
          type = repo.type
          env  = try(repo.env, [""])
        }
      ]
      proxies = [
        for proxy in try(project.proxies, []) : {
          name = coalesce(try(proxy.name, null), length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : "")
          type = proxy.type
        }
      ]
    }
  ]

  project_transform = [
    for project in local.calculated_repositories : {
      project_id = project.project_id
      short_code = project.short_code

      proxies_roles = [
        for proxy in project.proxies : "${proxy.name}-${proxy.type}-proxy-perm"
      ]
      repositories_roles = flatten([
        for repo in project.repositories : [
          for env in repo.env : "${repo.name}-${repo.type}${env != "" ? "-${env}" : ""}-perm"
        ]
      ])
    }
  ]
}
