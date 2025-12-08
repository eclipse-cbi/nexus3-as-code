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
          base_name   = coalesce(try(repo.name, null), length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : "")
          include_type_in_name = try(repo.include_type_in_name, true)
          include_env_in_name  = try(repo.include_env_in_name, true)
          custom_name          = try(repo.custom_name, null)
          group_suffix         = try(repo.group_suffix, "central")
          custom_group_name    = try(repo.custom_group_name, null)
          group       = [(
            try(repo.custom_name, null) != null ? (
              "${repo.custom_name}${try(repo.include_type_in_name, true) ? "-${repo.type}" : ""}${try(repo.include_env_in_name, true) && env != "" ? "-${env}" : ""}"
            ) : (
              try(repo.include_type_in_name, true) ? 
                "${coalesce(try(repo.name, null), length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : "")}-${repo.type}${try(repo.include_env_in_name, true) && env != "" ? "-${env}" : ""}" : 
                "${coalesce(try(repo.name, null), length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : "")}${try(repo.include_env_in_name, true) && env != "" ? "-${env}" : ""}"
            )
          )]
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
        base_name   = coalesce(try(proxy.name, null), length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : "")
        include_type_in_name = try(proxy.include_type_in_name, true)
        custom_name          = try(proxy.custom_name, null)
        group_suffix         = try(proxy.group_suffix, "central")
        custom_group_name    = try(proxy.custom_group_name, null)
        group       = []
        proxy_group = [(
          try(proxy.custom_name, null) != null ? (
            # With custom_name: add type if requested, always add "-proxy"
            "${proxy.custom_name}${try(proxy.include_type_in_name, true) ? "-${proxy.type}" : ""}-proxy"
          ) : (
            # Without custom_name: standard name generation with "-proxy"
            try(proxy.include_type_in_name, true) ? 
              "${coalesce(try(proxy.name, null), length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : "")}-${proxy.type}-proxy" : 
              "${coalesce(try(proxy.name, null), length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : "")}-proxy"
          )
        )]
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
      base_name   = try(v[0].base_name, length(split(".", k)) > 1 ? split(".", k)[1] : "")
      include_type_in_name = try(v[0].include_type_in_name, true)
      group_suffix = try(v[0].group_suffix, "central")  # Default suffix "central"
      custom_group_name = try(v[0].custom_group_name, null)
      group       = distinct(flatten([for g in v[*] : g.group if g.type == v[0].type]))
      proxy_group = distinct(flatten([for g in v[*] : g.proxy_group if g.type == v[0].type]))

    }
  ]

  docker_repositories_group = [
    for groups in local.transformed_repositories_groups :
    merge(var.default_repository_config, try(var.defaults.groups.docker.online, {}), groups, {
      base_name = coalesce(try(local.transformed_groups[groups.project_id].docker.name, null), groups.short_code)
      
      # Final group name
      final_name = (
        try(groups.custom_group_name, null) != null ? (
          # With custom_group_name: add type and/or suffix if requested
          "${groups.custom_group_name}${groups.include_type_in_name ? "-${groups.type}" : ""}${groups.group_suffix != "" && groups.group_suffix != null ? "-${groups.group_suffix}" : ""}"
        ) : try(local.transformed_groups[groups.project_id].docker.custom_name, null) != null ? (
          # With custom_name from groups config
          "${local.transformed_groups[groups.project_id].docker.custom_name}${groups.include_type_in_name ? "-${groups.type}" : ""}${groups.group_suffix != "" && groups.group_suffix != null ? "-${groups.group_suffix}" : ""}"
        ) : (
          # Standard name generation
          groups.group_suffix != "" && groups.group_suffix != null ? (
            groups.include_type_in_name ? "${coalesce(try(local.transformed_groups[groups.project_id].docker.name, null), groups.short_code)}-${groups.type}-${groups.group_suffix}" : "${coalesce(try(local.transformed_groups[groups.project_id].docker.name, null), groups.short_code)}-${groups.group_suffix}"
          ) : (
            groups.include_type_in_name ? "${coalesce(try(local.transformed_groups[groups.project_id].docker.name, null), groups.short_code)}-${groups.type}" : coalesce(try(local.transformed_groups[groups.project_id].docker.name, null), groups.short_code)
          )
        )
      )

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
      base_name = coalesce(try(local.transformed_groups[groups.project_id].maven2.name, null), groups.short_code)
      
      # Final group name
      final_name = (
        try(groups.custom_group_name, null) != null ? (
          # With custom_group_name: add type and/or suffix if requested
          "${groups.custom_group_name}${groups.include_type_in_name ? "-${groups.type}" : ""}${groups.group_suffix != "" && groups.group_suffix != null ? "-${groups.group_suffix}" : ""}"
        ) : try(local.transformed_groups[groups.project_id].maven2.custom_name, null) != null ? (
          # With custom_name from groups config
          "${local.transformed_groups[groups.project_id].maven2.custom_name}${groups.include_type_in_name ? "-${groups.type}" : ""}${groups.group_suffix != "" && groups.group_suffix != null ? "-${groups.group_suffix}" : ""}"
        ) : (
          # Standard name generation
          groups.group_suffix != "" && groups.group_suffix != null ? (
            groups.include_type_in_name ? "${coalesce(try(local.transformed_groups[groups.project_id].maven2.name, null), groups.short_code)}-${groups.type}-${groups.group_suffix}" : "${coalesce(try(local.transformed_groups[groups.project_id].maven2.name, null), groups.short_code)}-${groups.group_suffix}"
          ) : (
            groups.include_type_in_name ? "${coalesce(try(local.transformed_groups[groups.project_id].maven2.name, null), groups.short_code)}-${groups.type}" : coalesce(try(local.transformed_groups[groups.project_id].maven2.name, null), groups.short_code)
          )
        )
      )
      
      storage = merge(
        var.default_storage_config,
        try(var.defaults.groups.maven2.storage, {}),
        try(local.transformed_groups[groups.project_id].maven2.storage, {})
      )
    }) if groups.type == "maven2"
  ]

  npm_repositories_group = [
    for groups in local.transformed_repositories_groups : merge(var.default_repository_config, groups, {
      base_name = coalesce(try(local.transformed_groups[groups.project_id].npm.name, null), groups.short_code)
      
      # Final group name
      final_name = (
        try(groups.custom_group_name, null) != null ? (
          # With custom_group_name: add type and/or suffix if requested
          "${groups.custom_group_name}${groups.include_type_in_name ? "-${groups.type}" : ""}${groups.group_suffix != "" && groups.group_suffix != null ? "-${groups.group_suffix}" : ""}"
        ) : try(local.transformed_groups[groups.project_id].npm.custom_name, null) != null ? (
          # With custom_name from groups config
          "${local.transformed_groups[groups.project_id].npm.custom_name}${groups.include_type_in_name ? "-${groups.type}" : ""}${groups.group_suffix != "" && groups.group_suffix != null ? "-${groups.group_suffix}" : ""}"
        ) : (
          # Standard name generation
          groups.group_suffix != "" && groups.group_suffix != null ? (
            groups.include_type_in_name ? "${coalesce(try(local.transformed_groups[groups.project_id].npm.name, null), groups.short_code)}-${groups.type}-${groups.group_suffix}" : "${coalesce(try(local.transformed_groups[groups.project_id].npm.name, null), groups.short_code)}-${groups.group_suffix}"
          ) : (
            groups.include_type_in_name ? "${coalesce(try(local.transformed_groups[groups.project_id].npm.name, null), groups.short_code)}-${groups.type}" : coalesce(try(local.transformed_groups[groups.project_id].npm.name, null), groups.short_code)
          )
        )
      )
      
      storage = merge(
        var.default_storage_config,
        try(var.defaults.groups.npm.storage, {}),
        try(local.transformed_groups[groups.project_id].npm.storage, {})
      )
    }) if groups.type == "npm"
  ]

  pypi_repositories_group = [
    for groups in local.transformed_repositories_groups : merge(var.default_repository_config, groups, {
      base_name = coalesce(try(local.transformed_groups[groups.project_id].pypi.name, null), groups.short_code)
      
      # Final group name
      final_name = (
        try(groups.custom_group_name, null) != null ? (
          # With custom_group_name: add type and/or suffix if requested
          "${groups.custom_group_name}${groups.include_type_in_name ? "-${groups.type}" : ""}${groups.group_suffix != "" && groups.group_suffix != null ? "-${groups.group_suffix}" : ""}"
        ) : try(local.transformed_groups[groups.project_id].pypi.custom_name, null) != null ? (
          # With custom_name from groups config
          "${local.transformed_groups[groups.project_id].pypi.custom_name}${groups.include_type_in_name ? "-${groups.type}" : ""}${groups.group_suffix != "" && groups.group_suffix != null ? "-${groups.group_suffix}" : ""}"
        ) : (
          # Standard name generation
          groups.group_suffix != "" && groups.group_suffix != null ? (
            groups.include_type_in_name ? "${coalesce(try(local.transformed_groups[groups.project_id].pypi.name, null), groups.short_code)}-${groups.type}-${groups.group_suffix}" : "${coalesce(try(local.transformed_groups[groups.project_id].pypi.name, null), groups.short_code)}-${groups.group_suffix}"
          ) : (
            groups.include_type_in_name ? "${coalesce(try(local.transformed_groups[groups.project_id].pypi.name, null), groups.short_code)}-${groups.type}" : coalesce(try(local.transformed_groups[groups.project_id].pypi.name, null), groups.short_code)
          )
        )
      )
      
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
