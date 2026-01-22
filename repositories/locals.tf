locals {
  transform_repositories = flatten([
    for project in var.projects : [
      for repo in try(project.repositories, []) :
      merge(
        var.default_repository_config,
        try(var.defaults.repositories[repo.type].online, {}),
        repo,
        {
          project_id = project.project_id
          short_code = element(reverse(split(".", project.project_id)), 0)
          base_name  = coalesce(try(repo.name, null), element(reverse(split(".", project.project_id)), 0))

          # Name customization attributes
          include_type_in_name = try(repo.include_type_in_name, true) # Default: include type in name
          include_env_in_name  = try(repo.include_env_in_name, true)  # Default: include env in name
          custom_name          = try(repo.custom_name, null)          # Base custom name (type and env can still be added)

          # Final repository name construction
          name = (
            try(repo.custom_name, null) != null ? (
              # With custom_name: add type and/or env if requested
              "${repo.custom_name}${try(repo.include_type_in_name, true) ? "-${repo.type}" : ""}${try(repo.include_env_in_name, true) && try(repo.env, "") != "" ? "-${repo.env}" : ""}"
              ) : (
              # Without custom_name: standard name generation
              try(repo.include_type_in_name, true) ?
              "${coalesce(try(repo.name, null), element(reverse(split(".", project.project_id)), 0))}-${repo.type}${try(repo.include_env_in_name, true) && try(repo.env, "") != "" ? "-${repo.env}" : ""}" :
              "${coalesce(try(repo.name, null), element(reverse(split(".", project.project_id)), 0))}${try(repo.include_env_in_name, true) && try(repo.env, "") != "" ? "-${repo.env}" : ""}"
            )
          )

          env  = try(repo.env, "")
          type = repo.type

          storage = merge(
            var.default_storage_config,
            try(var.defaults.repositories[repo.type].storage, {}),
            # Override blob_store_name with project-specific blobstore if available and not explicitly set
            try(repo.storage.blob_store_name, null) == null ? (
              try(project.blobstore_name, null) != null ? {
                blob_store_name = project.blobstore_name
              } : (
                length(var.project_blobstores) > 0 && lookup(var.project_blobstores, project.project_id, null) != null ? {
                  blob_store_name = var.project_blobstores[project.project_id]
                } : {}
              )
            ) : {},
            try(repo.storage, {})
          )

          cleanup = merge(
            var.default_cleanup_config,
            try(var.defaults.repositories[repo.type].cleanup, {}),
            try(repo.cleanup, {})
          )

          component = merge(
            var.default_component_config,
            try(var.defaults.repositories[repo.type].component, {}),
            try(repo.component, {})
          )
      })
    ]
  ])

  docker_repositories = [
    for repo in local.transform_repositories : merge(repo, {
      docker = merge(
        var.default_docker_config,
        try(var.defaults.repositories.docker.docker, {}),
        try(repo.docker, {})
      )
    }) if repo.type == "docker"
  ]

  maven_repositories = [
    for repo in local.transform_repositories : merge(repo, {
      maven = merge(
        var.default_maven_config,
        try(var.defaults.repositories.maven2.maven, {}),
        try(repo.maven2, {})
      )
    }) if repo != null && repo.type == "maven2"
  ]

  npm_repositories = [
    for repo in local.transform_repositories : repo if repo != null && repo.type == "npm"
  ]

  helm_repositories = [
    for repo in local.transform_repositories : repo if repo != null && repo.type == "helm"
  ]

  pypi_repositories = [
    for repo in local.transform_repositories : repo if repo != null && repo.type == "pypi"
  ]

  apt_repositories = [
    for repo in local.transform_repositories : repo if repo != null && repo.type == "apt"
  ]

}
