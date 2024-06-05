locals {
  repositories = flatten([
    for project in var.projects : [
      for repo in coalesce(project.repositories, []) : [
        for env in try(repo.env, [""]) :
        {
          project_id = project.project_id
          short_code = length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : ""
          name       = coalesce(try(repo.name, null), length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : "")
          env        = env
          type       = repo.type
        }
      ]
    ]
  ])
  proxies = flatten([
    for project in var.projects : [
      for repo in try(project.proxies, []) : [
        {
          project_id = project.project_id
          short_code = length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : ""
          name       = coalesce(try(repo.name, null), length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : "")
          type       = repo.type

        }
      ]
    ]
  ])
}
