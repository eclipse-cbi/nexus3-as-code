locals {
  # Transform global proxies
  transform_global_proxies = flatten([
    for proxy in var.global_proxies : [
      merge(
        var.default_proxies_config,
        try(var.defaults.proxies[proxy.type].online, {}),
        proxy,
        {
          # Name customization attributes
          include_type_in_name = try(proxy.include_type_in_name, true)
          custom_name          = try(proxy.custom_name, null)
          proxy_suffix         = try(proxy.proxy_suffix, var.default_proxy_suffix)

          # Final proxy name construction (uses proxy_suffix)
          name = (
            try(proxy.custom_name, null) != null ? (
              # With custom_name: add type if requested, always add proxy_suffix
              "${proxy.custom_name}${try(proxy.include_type_in_name, true) ? "-${proxy.type}" : ""}${try(proxy.proxy_suffix, var.default_proxy_suffix)}"
              ) : (
              # Without custom_name: standard name generation with proxy_suffix
              try(proxy.include_type_in_name, true) ?
              "global-${proxy.type}${try(proxy.proxy_suffix, var.default_proxy_suffix)}" :
              "global${try(proxy.proxy_suffix, var.default_proxy_suffix)}"
            )
          )

          type = proxy.type

          storage = merge(
            var.default_storage_config,
            try(var.defaults.proxies[proxy.type].storage, {}),
            try(proxy.storage, {})
          )

          cleanup = merge(
            var.default_cleanup_config,
            try(var.defaults.proxies[proxy.type].cleanup, {}),
            try(proxy.cleanup, {})
          )

          negative_cache = merge(
            var.default_negative_cache_config,
            try(var.defaults.proxies[proxy.type].negative_cache, {}),
            try(proxy.negative_cache, {})
          )

          http_client = merge(
            var.default_http_client_config,
            try(var.defaults.proxies[proxy.type].http_client, {}),
            try(proxy.http_client, {})
          )

          proxy = merge(
            var.default_proxy_config,
            try(proxy.proxy, {}),
            {
              remote_url = proxy.remote_url
            }
          )
        }
      )
    ]
  ])

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
            custom_name          = try(repo.custom_name, null)          # Base custom name (type and proxy_suffix can still be added)
            proxy_suffix         = try(repo.proxy_suffix, var.default_proxy_suffix)

            # Final proxy name construction (uses proxy_suffix)
            name = (
              try(repo.custom_name, null) != null ? (
                # With custom_name: add type if requested, always add proxy_suffix
                "${repo.custom_name}${try(repo.include_type_in_name, true) ? "-${repo.type}" : ""}${try(repo.proxy_suffix, var.default_proxy_suffix)}"
                ) : (
                # Without custom_name: standard name generation with proxy_suffix
                try(repo.include_type_in_name, true) ?
                "${coalesce(try(repo.name, null), element(reverse(split(".", project.project_id)), 0))}-${repo.type}${try(repo.proxy_suffix, var.default_proxy_suffix)}" :
                "${coalesce(try(repo.name, null), element(reverse(split(".", project.project_id)), 0))}${try(repo.proxy_suffix, var.default_proxy_suffix)}"
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

  docker_proxies = concat(
    [
      for repo in local.transform_global_proxies : merge(repo, {
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
      }) if repo.type == "docker"
    ],
    [
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
  )

  maven_proxies = concat(
    [
      for repo in local.transform_global_proxies : merge(repo, {
        maven = merge(
          var.default_maven_config,
          try(repo.maven, {})
        )
        proxy = merge(
          var.default_proxy_config,
          try(repo.proxy, {})
        )
      }) if repo != null && repo.type == "maven2"
    ],
    [
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
  )

  npm_proxies = concat(
    [
      for repo in local.transform_global_proxies : merge(var.default_npm_proxies_config, repo, {
        proxy = merge(
          var.default_proxy_config,
          try(repo.proxy, {})
        )
      }) if repo != null && repo.type == "npm"
    ],
    [
      for repo in local.transform_proxies : merge(var.default_npm_proxies_config, repo, {
        proxy = merge(
          var.default_proxy_config,
          try(repo.proxy, {})
        )
        proxy = merge(var.default_proxy_config, try(repo.proxy, { "remote_url" : "https://npmjs.org/" }))
      }) if repo != null && repo.type == "npm"
    ]
  )

  helm_proxies = concat(
    [
      for repo in local.transform_global_proxies : merge(repo, {
        proxy = merge(
          var.default_proxy_config,
          try(repo.proxy, {})
        )
      }) if repo != null && repo.type == "helm"
    ],
    [
      for repo in local.transform_proxies : merge(repo, {
        proxy = merge(
          var.default_proxy_config,
          try(repo.proxy, {})
        )
        proxy = merge(var.default_proxy_config, try(repo.proxy, { "remote_url" : "https://kubernetes-charts.storage.googleapis.com/" }))
      }) if repo != null && repo.type == "helm"
    ]
  )

  pypi_proxies = concat(
    [
      for repo in local.transform_global_proxies : merge(repo, {
        proxy = merge(
          var.default_proxy_config,
          try(repo.proxy, {})
        )
      }) if repo != null && repo.type == "pypi"
    ],
    [
      for repo in local.transform_proxies : merge(repo, {
        proxy = merge(
          var.default_proxy_config,
          try(repo.proxy, {})
        )
        proxy = merge(var.default_proxy_config, try(repo.proxy, { "remote_url" : "https://pypi.org" }))
      }) if repo != null && repo.type == "pypi"
    ]
  )

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
