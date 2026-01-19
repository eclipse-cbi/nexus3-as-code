locals {
  calculated_projects = [
    for project in var.projects : {
      project_id = project.project_id
      short_code = length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : ""
      archived   = try(project.archived, false)
      repositories : try(project.repositories, [])
      proxies : try(project.proxies, [])
    }
  ]
  # Filter out archived projects - no users created for archived projects
  project_transform = [
    for project in local.calculated_projects : {
      project_id = project.project_id
      short_code = project.short_code
      roles_repository : length(project.repositories) > 0 ? ["${project.short_code}-repository-bot-role"] : []
      roles_proxy : length(project.proxies) > 0 ? ["${project.short_code}-proxy-bot-role"] : []
    } if !project.archived
  ]
}
