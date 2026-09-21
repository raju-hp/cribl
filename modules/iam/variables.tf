variable "project" {
  description = "Project name prefix for IAM resources"
  type        = string
}

variable "tags" {
  description = "Common tags for IAM resources"
  type        = map(string)
  default     = {}
}

variable "enable_s3_access" {
  description = "Whether to attach S3 read/write permissions to EC2 roles"
  type        = bool
  default     = false
}

variable "s3_allowed_buckets" {
  description = "List of S3 bucket ARNs the Cribl nodes can access"
  type        = list(string)
  default     = []
}
