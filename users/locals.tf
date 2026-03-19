locals {
  calculated_projects = [
    for project in var.projects : {
      project_id = project.project_id
      # bot_code is always derived from project_id, never from shortNameOverride
      bot_code = element(reverse(split(".", project.project_id)), 0)
      archived   = try(project.archived, false)
      repositories : try(project.repositories, [])
      proxies : try(project.proxies, [])
      shared_perms_from = try(project.shared_perms_from, null)
    }
  ]
  
  # Create a map of project_id to roles for easy lookup
  # Roles use bot_code (based on project_id)
  project_roles_map = {
    for project in local.calculated_projects : project.project_id => {
      roles_repository : length(project.repositories) > 0 ? ["${project.bot_code}-repository-bot-role"] : []
      roles_proxy : length(project.proxies) > 0 ? ["${project.bot_code}-proxy-bot-role"] : []
    }
  }
  
  # Filter out archived projects - no users created for archived projects
  project_transform = [
    for project in local.calculated_projects : {
      project_id = project.project_id
      bot_code = project.bot_code
      # Each project uses its own role based on bot_code, regardless of shared_perms_from
      # The roles module will ensure the role has the correct permissions
      roles_repository : length(project.repositories) > 0 || project.shared_perms_from != null ? (
        ["${project.bot_code}-repository-bot-role"]
      ) : []
      roles_proxy : length(project.proxies) > 0 || project.shared_perms_from != null ? (
        ["${project.bot_code}-proxy-bot-role"]
      ) : []
    } if !project.archived
  ]
}
