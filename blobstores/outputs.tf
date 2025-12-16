# Output for debugging
output "project_blobstores" {
  description = "Map of project_id to blobstore name"
  value = {
    for k, v in local.project_blobstores : k => v.name
  }
}
