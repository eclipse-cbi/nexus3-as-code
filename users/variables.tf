variable "projects" {
  description = "List of projects to create bot users for"
  default     = []
}

variable "repo_address" {
  description = "The Nexus Repository address"
  type        = string
}

variable "secretsmanager_path" {
  description = "Path suffix for secrets in Vault"
  type        = string
  default     = "repo.eclipse.org"
}

variable "project_roles" {
  description = "Map of project roles created by the roles module (for implicit dependency)"
  type        = any
  default     = {}
}