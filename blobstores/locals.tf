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
      shared_perms_from  = try(project.shared_perms_from, null) # Projects sharing perms don't need blobstores
    }
  }

  # Global proxy blobstores (deduplicated by blob_store_name)
  global_proxy_blobstores_grouped = {
    for proxy in var.global_proxies : 
      try(proxy.storage.blob_store_name, "default") => {
        name             = try(proxy.storage.blob_store_name, "default")
        soft_quota_limit = coalesce(try(proxy.storage.blobstore_soft_quota_limit, null), var.default_soft_quota_limit)
        soft_quota_type  = coalesce(try(proxy.storage.blobstore_soft_quota_type, null), var.default_soft_quota_type)
      }...
    if try(proxy.storage.blob_store_name, "default") != "default"
  }

  # Flatten to get unique blobstores
  global_proxy_blobstores = {
    for name, items in local.global_proxy_blobstores_grouped :
      name => items[0]
  }

  # Blobstores to create (only for projects without explicit blobstore_name and without shared_perms_from)
  blobstores_to_create = merge(
    {
      for k, v in local.project_blobstores : k => v
      if v.external_blobstore == false && v.shared_perms_from == null
    },
    local.global_proxy_blobstores
  )
}
