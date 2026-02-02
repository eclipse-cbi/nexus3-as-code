variable "projects" {
  description = "List of projects to create blob stores for"
}

variable "global_proxies" {
  description = "List of global proxies that may need blob stores"
  type        = list(any)
  default     = []
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
