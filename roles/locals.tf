locals {
  # Calculate repository names using the same logic as repositories/locals.tf
  calculated_repositories = [
    for project in var.projects : {
      project_id = project.project_id
      short_code = length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : project.project_id
      repositories = [
        for repo in try(project.repositories, []) : {
          base_name            = coalesce(try(repo.name, null), length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : "")
          type                 = repo.type
          env                  = try(repo.env, "")
          include_type_in_name = try(repo.include_type_in_name, true)
          include_env_in_name  = try(repo.include_env_in_name, true)
          custom_name          = try(repo.custom_name, null)
          
          # Final repository name (same logic as repositories/locals.tf)
          name = (
            try(repo.custom_name, null) != null ? (
              "${repo.custom_name}${try(repo.include_type_in_name, true) ? "-${repo.type}" : ""}${try(repo.include_env_in_name, true) && try(repo.env, "") != "" ? "-${repo.env}" : ""}"
              ) : (
              try(repo.include_type_in_name, true) ?
              "${coalesce(try(repo.name, null), length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : "")}-${repo.type}${try(repo.include_env_in_name, true) && try(repo.env, "") != "" ? "-${repo.env}" : ""}" :
              "${coalesce(try(repo.name, null), length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : "")}${try(repo.include_env_in_name, true) && try(repo.env, "") != "" ? "-${repo.env}" : ""}"
            )
          )
        }
      ]
      proxies = [
        for proxy in try(project.proxies, []) : {
          base_name            = coalesce(try(proxy.name, null), length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : "")
          type                 = proxy.type
          include_type_in_name = try(proxy.include_type_in_name, true)
          custom_name          = try(proxy.custom_name, null)
          
          # Final proxy name (same logic as proxies/locals.tf - always ends with "-proxy")
          name = (
            try(proxy.custom_name, null) != null ? (
              "${proxy.custom_name}${try(proxy.include_type_in_name, true) ? "-${proxy.type}" : ""}-proxy"
              ) : (
              try(proxy.include_type_in_name, true) ?
              "${coalesce(try(proxy.name, null), length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : "")}-${proxy.type}-proxy" :
              "${coalesce(try(proxy.name, null), length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : "")}-proxy"
            )
          )
        }
      ]
    }
  ]

  project_transform = [
    for project in local.calculated_repositories : {
      project_id = project.project_id
      short_code = project.short_code

      # Use computed names + "-perm" suffix
      proxies_roles = [
        for proxy in project.proxies : "${proxy.name}-perm"
      ]
      repositories_roles = [
        for repo in project.repositories : "${repo.name}-perm"
      ]
    }
  ]
}
