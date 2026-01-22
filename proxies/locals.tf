locals {
  transform_proxies = flatten([
    for project in var.projects : [
      for repo in try(project.proxies, []) : [
        merge(
          var.default_proxies_config,
          try(var.defaults.proxies[repo.type].online, {}),
          repo,
          {
            project_id = project.project_id
            short_code = element(reverse(split(".", project.project_id)), 0)
            base_name  = coalesce(try(repo.name, null), element(reverse(split(".", project.project_id)), 0))

            # Name customization attributes
            include_type_in_name = try(repo.include_type_in_name, true) # Default: include type in name
            custom_name          = try(repo.custom_name, null)          # Base custom name (type and "proxy" can still be added)

            # Final proxy name construction (always includes "-proxy" suffix)
            name = (
              try(repo.custom_name, null) != null ? (
                # With custom_name: add type if requested, always add "-proxy"
                "${repo.custom_name}${try(repo.include_type_in_name, true) ? "-${repo.type}" : ""}-proxy"
                ) : (
                # Without custom_name: standard name generation with "-proxy"
                try(repo.include_type_in_name, true) ?
                "${coalesce(try(repo.name, null), element(reverse(split(".", project.project_id)), 0))}-${repo.type}-proxy" :
                "${coalesce(try(repo.name, null), element(reverse(split(".", project.project_id)), 0))}-proxy"
              )
            )

            type = repo.type

            storage = merge(
              var.default_storage_config,
              try(var.defaults.proxies[repo.type].storage, {}),
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
              try(var.defaults.proxies[repo.type].cleanup, {}),
              try(repo.cleanup, {})
            )

            negative_cache = merge(
              var.default_negative_cache_config,
              try(var.defaults.proxies[repo.type].negative_cache, {}),
              try(repo.negative_cache, {})
            )

            http_client = merge(
              var.default_http_client_config,
              try(var.defaults.proxies[repo.type].http_client, {}),
              try(repo.http_client, {})
            )
          }
        )
      ]
    ]
  ])

  docker_proxies = [
    for repo in local.transform_proxies : merge(repo, {
      docker = merge(
        var.default_docker_config,
        try(repo.docker, {})
      )
      docker_proxy = merge(
        var.default_docker_proxy_config,
        try(repo.docker_proxy, {})
      )
      proxy = merge(
        var.default_proxy_config,
        try(repo.proxy, {})
      )
      proxy = merge(var.default_proxy_config, try(repo.proxy, { "remote_url" : "https://registry-1.docker.io" }))

    }) if repo.type == "docker"
  ]

  maven_proxies = [
    for repo in local.transform_proxies : merge(repo, {
      maven = merge(
        var.default_maven_config,
        try(repo.maven2, {})
      )
      proxy = merge(
        var.default_proxy_config,
        try(repo.proxy, {})
      )
      proxy = merge(var.default_proxy_config, try(repo.proxy, { "remote_url" : "https://repo1.maven.org/maven2/" }))
    }) if repo != null && repo.type == "maven2"
  ]

  npm_proxies = [
    for repo in local.transform_proxies : merge(var.default_npm_proxies_config, repo, {
      proxy = merge(
        var.default_proxy_config,
        try(repo.proxy, {})
      )
      proxy = merge(var.default_proxy_config, try(repo.proxy, { "remote_url" : "https://npmjs.org/" }))
    }) if repo != null && repo.type == "npm"
  ]

  helm_proxies = [
    for repo in local.transform_proxies : merge(repo, {
      proxy = merge(
        var.default_proxy_config,
        try(repo.proxy, {})
      )
      proxy = merge(var.default_proxy_config, try(repo.proxy, { "remote_url" : "https://kubernetes-charts.storage.googleapis.com/" }))
    }) if repo != null && repo.type == "helm"
  ]

  pypi_proxies = [
    for repo in local.transform_proxies : merge(repo, {
      proxy = merge(
        var.default_proxy_config,
        try(repo.proxy, {})
      )
      proxy = merge(var.default_proxy_config, try(repo.proxy, { "remote_url" : "https://pypi.org" }))
    }) if repo != null && repo.type == "pypi"
  ]

  apt_proxies = [
    for repo in local.transform_proxies : merge(repo, {
      apt = merge(
        {
          distribution = "bionic"
          flat         = false
        },
        try(var.defaults.proxies.apt.apt, {}),
        try(repo.apt, {})
      )
      proxy = merge(var.default_proxy_config, try(repo.proxy, { "remote_url" : "http://archive.ubuntu.com/ubuntu/" }))
    }) if repo != null && repo.type == "apt"
  ]
}
