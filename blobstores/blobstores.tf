# Nexus blob stores per project
resource "nexus_blobstore_file" "project_blobstore" {
  for_each = local.blobstores_to_create

  name = each.value.name
  path = "/blobs-${each.value.short_code}"

  soft_quota {
    limit = each.value.soft_quota_limit * 1024 * 1024 * 1024 # Convert GB to bytes
    type  = each.value.soft_quota_type
  }
}
