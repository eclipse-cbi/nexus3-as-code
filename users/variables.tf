variable "projects" {
  description = "List of projects to create bot users for"
  default     = []
}

variable "repo_address" {
  description = "The Nexus Repository address"
  type        = string
}