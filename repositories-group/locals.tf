locals {

  transformed_groups = {
    for project in var.projects :
    project.project_id => {
      for group in try(project.groups, []) :
      group.type => group
    }
  }

  transformed_repos = [
    for project in var.projects : flatten([
      for repo in try(project.repositories, []) : [
        for env in try(repo.env, [""]) : {
          project_id  = project.project_id
          type        = repo.type
          group       = ["${coalesce(try(repo.name, null), length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : "")}-${repo.type}${env != "" ? "-${env}" : ""}"]
          proxy_group = []
        }
      ]
    ])
  ]

  transformed_proxies = [
    for project in var.projects : [
      for proxy in try(project.proxies, []) : {
        project_id  = project.project_id
        type        = proxy.type
        group       = []
        proxy_group = ["${coalesce(try(proxy.name, null), length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : "")}-${proxy.type}-proxy"]
      }
    ]
  ]

  combined = flatten(concat(local.transformed_repos, local.transformed_proxies))

  transformed_repositories_groups = [
    for k, v in { for a in local.combined : a.project_id => a... } :
    {
      project_id  = k
      type        = v[0].type
      short_code  = length(split(".", k)) > 1 ? split(".", k)[1] : ""
      group       = distinct(flatten([for g in v[*] : g.group if g.type == v[0].type]))
      proxy_group = distinct(flatten([for g in v[*] : g.proxy_group if g.type == v[0].type]))

    }
  ]

  docker_repositories_group = [
    for groups in local.transformed_repositories_groups :
    merge(var.default_repository_config, try(var.defaults.groups.docker.online, {}), groups, {
      name = coalesce(try(local.transformed_groups[groups.project_id].docker.name, null), groups.short_code)

      docker = merge(
        var.default_docker_config,
        try(var.defaults.groups.docker.docker, {}),
        try(local.transformed_groups[groups.project_id].docker.docker, {})
      )
      storage = merge(
        var.default_storage_config,
        try(var.defaults.groups.docker.storage, {}),
        try(local.transformed_groups[groups.project_id].docker.storage, {})
      )
    }) if groups.type == "docker"
  ]

  maven_repositories_group = [
    for groups in local.transformed_repositories_groups : merge(var.default_repository_config, groups, {
      name = coalesce(try(local.transformed_groups[groups.project_id].maven2.name, null), groups.short_code)
      storage = merge(
        var.default_storage_config,
        try(var.defaults.groups.maven2.storage, {}),
        try(local.transformed_groups[groups.project_id].maven2.storage, {})
      )
    }) if groups.type == "maven2"
  ]

  npm_repositories_group = [
    for groups in local.transformed_repositories_groups : merge(var.default_repository_config, groups, {
      name = coalesce(try(local.transformed_groups[groups.project_id].npm.name, null), groups.short_code)
      storage = merge(
        var.default_storage_config,
        try(var.defaults.groups.npm.storage, {}),
        try(local.transformed_groups[groups.project_id].npm.storage, {})
      )
    }) if groups.type == "npm"
  ]

  pypi_repositories_group = [
    for groups in local.transformed_repositories_groups : merge(var.default_repository_config, groups, {
      name = coalesce(try(local.transformed_groups[groups.project_id].pypi.name, null), groups.short_code)
      storage = merge(
        var.default_storage_config,
        try(var.defaults.groups.pypi.storage, {}),
        try(local.transformed_groups[groups.project_id].pypi.storage, {})
      )
    }) if groups.type == "pypi"
  ]
}

output "transformed_projects" {
  value = local.docker_repositories_group
}
