locals {
  repositories = flatten([
    for project in var.projects : [
      for repo in try(project.repositories, []) :
      {
        project_id           = project.project_id
        short_code           = element(reverse(split(".", project.project_id)), 0)
        base_name            = coalesce(try(repo.name, null), element(reverse(split(".", project.project_id)), 0))
        env                  = try(repo.env, "")
        type                 = repo.type
        include_type_in_name = try(repo.include_type_in_name, true)
        include_env_in_name  = try(repo.include_env_in_name, true)
        custom_name          = try(repo.custom_name, null)

        # Final repository name construction (same logic as repositories/locals.tf)
        name = (
          try(repo.custom_name, null) != null ? (
            "${repo.custom_name}${try(repo.include_type_in_name, true) ? "-${repo.type}" : ""}${try(repo.include_env_in_name, true) && try(repo.env, "") != "" ? "-${repo.env}" : ""}"
            ) : (
            try(repo.include_type_in_name, true) ?
            "${coalesce(try(repo.name, null), element(reverse(split(".", project.project_id)), 0))}-${repo.type}${try(repo.include_env_in_name, true) && try(repo.env, "") != "" ? "-${repo.env}" : ""}" :
            "${coalesce(try(repo.name, null), element(reverse(split(".", project.project_id)), 0))}${try(repo.include_env_in_name, true) && try(repo.env, "") != "" ? "-${repo.env}" : ""}"
          )
        )
      }
    ]
  ])
  
  proxies = flatten([
    for project in var.projects : [
      for proxy in try(project.proxies, []) :
      {
        project_id           = project.project_id
        short_code           = element(reverse(split(".", project.project_id)), 0)
        base_name            = coalesce(try(proxy.name, null), element(reverse(split(".", project.project_id)), 0))
        type                 = proxy.type
        include_type_in_name = try(proxy.include_type_in_name, true)
        custom_name          = try(proxy.custom_name, null)

        # Final proxy name construction (same logic as proxies/locals.tf - always ends with "-proxy")
        name = (
          try(proxy.custom_name, null) != null ? (
            "${proxy.custom_name}${try(proxy.include_type_in_name, true) ? "-${proxy.type}" : ""}-proxy"
            ) : (
            try(proxy.include_type_in_name, true) ?
            "${coalesce(try(proxy.name, null), element(reverse(split(".", project.project_id)), 0))}-${proxy.type}-proxy" :
            "${coalesce(try(proxy.name, null), element(reverse(split(".", project.project_id)), 0))}-proxy"
          )
        )
      }
    ]
  ])
}
