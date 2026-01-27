locals {

  transformed_groups = {
    for project in var.projects :
    project.project_id => {
      for idx, group in try(project.groups, []) :
      "${group.type}-${idx}" => group
    }
  }

  transformed_repos = [
    for project in var.projects : flatten([
      for repo in try(project.repositories, []) : {
        project_id           = project.project_id
        type                 = repo.type
        base_name            = coalesce(try(repo.name, null), element(reverse(split(".", project.project_id)), 0))
        include_type_in_name = try(repo.include_type_in_name, true)
        include_env_in_name  = try(repo.include_env_in_name, true)
        custom_name          = try(project.group_custom_name, try(repo.custom_name, null))
        group_suffix         = try(repo.group_suffix, "")
        custom_group_name    = try(repo.custom_group_name, null)
        env                  = try(repo.env, "")
        group = [(
          try(repo.custom_name, null) != null ? (
            "${repo.custom_name}${try(repo.include_type_in_name, true) ? "-${repo.type}" : ""}${try(repo.include_env_in_name, true) && try(repo.env, "") != "" ? "-${repo.env}" : ""}"
            ) : (
            try(repo.include_type_in_name, true) ?
            "${coalesce(try(repo.name, null), element(reverse(split(".", project.project_id)), 0))}-${repo.type}${try(repo.include_env_in_name, true) && try(repo.env, "") != "" ? "-${repo.env}" : ""}" :
            "${coalesce(try(repo.name, null), element(reverse(split(".", project.project_id)), 0))}${try(repo.include_env_in_name, true) && try(repo.env, "") != "" ? "-${repo.env}" : ""}"
          )
        )]
        proxy_group = []
      }
    ])
  ]

  transformed_proxies = [
    for project in var.projects : [
      for proxy in try(project.proxies, []) : {
        project_id           = project.project_id
        type                 = proxy.type
        base_name            = coalesce(try(proxy.name, null), element(reverse(split(".", project.project_id)), 0))
        include_type_in_name = try(proxy.include_type_in_name, true)
        custom_name          = try(proxy.custom_name, null)
        group_suffix         = try(proxy.group_suffix, "")
        custom_group_name    = try(proxy.custom_group_name, null)
        group                = []
        proxy_group = [(
          try(proxy.custom_name, null) != null ? (
            # With custom_name: add type if requested, always add "-proxy"
            "${proxy.custom_name}${try(proxy.include_type_in_name, true) ? "-${proxy.type}" : ""}-proxy"
            ) : (
            # Without custom_name: standard name generation with "-proxy"
            try(proxy.include_type_in_name, true) ?
            "${coalesce(try(proxy.name, null), element(reverse(split(".", project.project_id)), 0))}-${proxy.type}-proxy" :
            "${coalesce(try(proxy.name, null), element(reverse(split(".", project.project_id)), 0))}-proxy"
          )
        )]
      }
    ]
  ]

  combined = flatten(concat(local.transformed_repos, local.transformed_proxies))

  # Standard groups from repositories and proxies
  transformed_repositories_groups = [
    for k, v in { for a in local.combined : a.project_id => a... } :
    {
      project_id           = k
      type                 = v[0].type
      short_code           = element(reverse(split(".", k)), 0)
      base_name            = try(v[0].base_name, element(reverse(split(".", k)), 0))
      include_type_in_name = try(v[0].include_type_in_name, true)
      group_suffix         = try(v[0].group_suffix, "")
      custom_group_name    = try(v[0].custom_group_name, null)
      group                = distinct(flatten([for g in v[*] : g.group if g.type == v[0].type]))
      proxy_group          = distinct(flatten([for g in v[*] : g.proxy_group if g.type == v[0].type]))
      custom_members       = null # No custom members for auto-generated groups
    }
    # Filter out projects that have create_group_auto = false (default behavior)
    if try([for project in var.projects : project.create_group_auto if project.project_id == k][0], false) == true
  ]

  # Custom groups with explicit members from groups configuration
  custom_groups = flatten([
    for project in var.projects : [
      for group in try(project.groups, []) : {
        project_id           = project.project_id
        type                 = group.type
        short_code           = element(reverse(split(".", project.project_id)), 0)
        base_name            = try(group.name, element(reverse(split(".", project.project_id)), 0))
        include_type_in_name = try(group.include_type_in_name, false)
        group_suffix         = try(group.group_suffix, "")
        custom_group_name    = try(group.custom_group_name, null)
        custom_name          = try(group.custom_name, null)
        group                = []
        proxy_group          = []
        custom_members       = try(group.members, null)
        online               = try(group.online, true)
      } if try(group.members, null) != null # Only include groups with explicit members
    ]
  ])

  # Collect all repositories by type and env for global groups
  all_repositories_by_type_env = flatten([
    for project in var.projects : [
      for repo in try(project.repositories, []) : {
        name = (
          try(repo.custom_name, null) != null ? (
            "${repo.custom_name}${try(repo.include_type_in_name, true) ? "-${repo.type}" : ""}${try(repo.include_env_in_name, true) && try(repo.env, "") != "" ? "-${repo.env}" : ""}"
            ) : (
            try(repo.include_type_in_name, true) ?
            "${coalesce(try(repo.name, null), element(reverse(split(".", project.project_id)), 0))}-${repo.type}${try(repo.include_env_in_name, true) && try(repo.env, "") != "" ? "-${repo.env}" : ""}" :
            "${coalesce(try(repo.name, null), element(reverse(split(".", project.project_id)), 0))}${try(repo.include_env_in_name, true) && try(repo.env, "") != "" ? "-${repo.env}" : ""}"
          )
        )
        type = repo.type
        env  = try(repo.env, "internal")
      }
    ]
  ])

  # Create global groups with auto_collect
  global_groups = flatten([
    for group in var.global_groups : {
      project_id           = "global"  # Virtual project for global groups
      type                 = group.type
      short_code           = "global"
      base_name            = try(group.custom_name, "global")
      include_type_in_name = try(group.include_type_in_name, false)
      group_suffix         = ""
      custom_group_name    = null
      custom_name          = try(group.custom_name, null)
      group                = []
      proxy_group          = []
      online               = true
      # Auto-collect matching repositories if auto_collect is defined
      custom_members = try(group.auto_collect, null) != null ? [
        for repo in local.all_repositories_by_type_env :
        repo.name
        if repo.type == group.auto_collect.type && repo.env == group.auto_collect.env
      ] : []
    }
  ])

  # Merge standard, custom, and global groups
  all_repositories_groups = concat(local.transformed_repositories_groups, local.custom_groups, local.global_groups)

  docker_repositories_group = [
    for groups in local.all_repositories_groups :
    merge(var.default_repository_config, try(var.defaults.groups.docker.online, {}), groups, {
      base_name = coalesce(try(local.transformed_groups[groups.project_id].docker.name, null), groups.short_code)

      # Final group name - support custom groups with explicit custom_name
      final_name = (
        try(groups.custom_name, null) != null ? (
          # Custom name from group definition (for custom groups with members)
          "${groups.custom_name}${groups.include_type_in_name ? "-${groups.type}" : ""}${groups.group_suffix != "" && groups.group_suffix != null ? "-${groups.group_suffix}" : ""}"
          ) : try(groups.custom_group_name, null) != null ? (
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
        try(local.transformed_groups[groups.project_id].docker.storage, {}),
        # Override blob_store_name with project-specific blobstore if available
        length(var.project_blobstores) > 0 && lookup(var.project_blobstores, groups.project_id, null) != null ? {
          blob_store_name = var.project_blobstores[groups.project_id]
        } : {}
      )
    }) if groups.type == "docker"
  ]

  maven_repositories_group = [
    for groups in local.all_repositories_groups : merge(var.default_repository_config, groups, {
      base_name = coalesce(try(local.transformed_groups[groups.project_id].maven2.name, null), groups.short_code)

      # Final group name - support custom groups with explicit custom_name
      final_name = (
        try(groups.custom_name, null) != null ? (
          # Custom name from group definition (for custom groups with members)
          "${groups.custom_name}${groups.include_type_in_name ? "-${groups.type}" : ""}${groups.group_suffix != "" && groups.group_suffix != null ? "-${groups.group_suffix}" : ""}"
          ) : try(groups.custom_group_name, null) != null ? (
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
        try(local.transformed_groups[groups.project_id].maven2.storage, {}),
        # Override blob_store_name with project-specific blobstore if available
        length(var.project_blobstores) > 0 && lookup(var.project_blobstores, groups.project_id, null) != null ? {
          blob_store_name = var.project_blobstores[groups.project_id]
        } : {}
      )

      maven = merge(
        var.default_maven_config,
        try(var.defaults.repositories.maven2.maven, {}),
        try(groups.maven2, {})
      )
    }) if groups.type == "maven2"
  ]

  npm_repositories_group = [
    for groups in local.all_repositories_groups : merge(var.default_repository_config, groups, {
      base_name = coalesce(try(local.transformed_groups[groups.project_id].npm.name, null), groups.short_code)

      # Final group name - support custom groups with explicit custom_name
      final_name = (
        try(groups.custom_name, null) != null ? (
          # Custom name from group definition (for custom groups with members)
          "${groups.custom_name}${groups.include_type_in_name ? "-${groups.type}" : ""}${groups.group_suffix != "" && groups.group_suffix != null ? "-${groups.group_suffix}" : ""}"
          ) : try(groups.custom_group_name, null) != null ? (
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
        try(local.transformed_groups[groups.project_id].npm.storage, {}),
        # Override blob_store_name with project-specific blobstore if available
        length(var.project_blobstores) > 0 && lookup(var.project_blobstores, groups.project_id, null) != null ? {
          blob_store_name = var.project_blobstores[groups.project_id]
        } : {}
      )
    }) if groups.type == "npm"
  ]

  pypi_repositories_group = [
    for groups in local.all_repositories_groups : merge(var.default_repository_config, groups, {
      base_name = coalesce(try(local.transformed_groups[groups.project_id].pypi.name, null), groups.short_code)

      # Final group name - support custom groups with explicit custom_name
      final_name = (
        try(groups.custom_name, null) != null ? (
          # Custom name from group definition (for custom groups with members)
          "${groups.custom_name}${groups.include_type_in_name ? "-${groups.type}" : ""}${groups.group_suffix != "" && groups.group_suffix != null ? "-${groups.group_suffix}" : ""}"
          ) : try(groups.custom_group_name, null) != null ? (
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
        try(local.transformed_groups[groups.project_id].pypi.storage, {}),
        # Override blob_store_name with project-specific blobstore if available
        length(var.project_blobstores) > 0 && lookup(var.project_blobstores, groups.project_id, null) != null ? {
          blob_store_name = var.project_blobstores[groups.project_id]
        } : {}
      )
    }) if groups.type == "pypi"
  ]
}

output "transformed_projects" {
  value = local.docker_repositories_group
}
