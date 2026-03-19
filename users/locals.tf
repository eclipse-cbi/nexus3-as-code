locals {
  calculated_projects = [
    for project in var.projects : {
      project_id = project.project_id
      short_code = element(reverse(split(".", project.project_id)), 0)
      archived   = try(project.archived, false)
      repositories : try(project.repositories, [])
      proxies : try(project.proxies, [])
      shared_perms_from = try(project.shared_perms_from, null)
    }
  ]
  
  # Create a map of project_id to roles for easy lookup
  project_roles_map = {
    for project in local.calculated_projects : project.project_id => {
      roles_repository : length(project.repositories) > 0 ? ["${project.short_code}-repository-bot-role"] : []
      roles_proxy : length(project.proxies) > 0 ? ["${project.short_code}-proxy-bot-role"] : []
    }
  }
  
  # Filter out archived projects - no users created for archived projects
  project_transform = [
    for project in local.calculated_projects : {
      project_id = project.project_id
      short_code = project.short_code
      # Each project uses its own role based on short_code, regardless of shared_perms_from
      # The roles module will ensure the role has the correct permissions
      roles_repository : length(project.repositories) > 0 || project.shared_perms_from != null ? (
        ["${project.short_code}-repository-bot-role"]
      ) : []
      roles_proxy : length(project.proxies) > 0 || project.shared_perms_from != null ? (
        ["${project.short_code}-proxy-bot-role"]
      ) : []
    } if !project.archived
  ]
}
