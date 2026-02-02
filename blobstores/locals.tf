locals {
  # Complete map of all project blobstores
  project_blobstores = {
    for project in var.projects : project.project_id => {
      project_id         = project.project_id
      short_code         = element(reverse(split(".", project.project_id)), 0)
      name               = try(project.blobstore_name, null) != null ? project.blobstore_name : replace(project.project_id, ".", "-")
      soft_quota_limit   = try(project.blobstore_soft_quota_limit, var.default_soft_quota_limit)
      soft_quota_type    = try(project.blobstore_soft_quota_type, var.default_soft_quota_type)
      external_blobstore = try(project.external_blobstore, false) # true if blobstore already exists
    }
  }

  # Global proxy blobstores
  global_proxy_blobstores = {
    for proxy in var.global_proxies : 
      try(proxy.storage.blob_store_name, "default") => {
        name             = try(proxy.storage.blob_store_name, "default")
        soft_quota_limit = try(proxy.storage.soft_quota_limit, var.default_soft_quota_limit)
        soft_quota_type  = try(proxy.storage.soft_quota_type, var.default_soft_quota_type)
      }
    if try(proxy.storage.blob_store_name, "default") != "default"
  }

  # Blobstores to create (only for projects without explicit blobstore_name)
  blobstores_to_create = merge(
    {
      for k, v in local.project_blobstores : k => v
      if v.external_blobstore == false
    },
    local.global_proxy_blobstores
  )
}
