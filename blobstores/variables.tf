variable "projects" {
  description = "List of projects to create blob stores for"
}

variable "default_soft_quota_limit" {
  description = "Default soft quota limit in GB"
  type        = number
  default     = 45
}

variable "default_soft_quota_type" {
  description = "Default soft quota type"
  type        = string
  default     = "spaceUsedQuota"
}
