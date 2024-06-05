locals {
  transform_repositories = flatten([
    for project in var.projects : [
      for repo in coalesce(project.repositories, []) : [
        for env in try(repo.env, [""]) :
        merge(
          var.default_repository_config,
          try(var.defaults.repositories[repo.type].online, {}),
          repo,
          {
            project_id = project.project_id
            short_code = length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : ""
            name       = coalesce(try(repo.name, null), length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : "")

            env  = env
            type = repo.type

            storage = merge(
              var.default_storage_config,
              try(var.defaults.repositories[repo.type].storage, {}),
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

}
