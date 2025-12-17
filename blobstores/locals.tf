locals {
  # Generate a unique blobstore for each project_id, unless blobstore_name is provided (external blobstore)
  project_blobstores = {
    for project in var.projects : project.project_id => {
      project_id       = project.project_id
      short_code       = length(split(".", project.project_id)) > 1 ? split(".", project.project_id)[1] : project.project_id
      name             = replace(project.project_id, ".", "-")
      soft_quota_limit = try(project.blobstore_soft_quota_limit, var.default_soft_quota_limit)
      soft_quota_type  = try(project.blobstore_soft_quota_type, var.default_soft_quota_type)
    }
    if try(project.blobstore_name, null) == null
  }
}
