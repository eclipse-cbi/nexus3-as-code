# Nexus blob stores per project and global proxies
resource "nexus_blobstore_file" "project_blobstore" {
  for_each = local.blobstores_to_create

  name = each.value.name
  path = try(each.value.short_code, null) != null ? "/blobs-${each.value.short_code}" : "/${each.value.name}"

  soft_quota {
    limit = each.value.soft_quota_limit * 1024 * 1024 * 1024 # Convert GB to bytes
    type  = each.value.soft_quota_type
  }
}
