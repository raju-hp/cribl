variable "name" {
  type        = string
  description = "Name prefix for leader instance"
}

variable "instance_type" {
  type        = string
  description = "Instance type for Cribl leader"
}

variable "instance_profile" {
  type        = string
  description = "IAM instance profile name for Cribl leader"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnets for leader"
}

variable "security_groups" {
  type        = list(string)
  description = "List of security groups"
}

variable "key_name" {
  type        = string
  description = "SSH key name"
}

variable "tags" {
  type        = map(string)
  description = "Common tags"
}

variable "cribl_dir" {
  description = "Cribl install dir"
  type        = string
  default     = "/opt/cribl"
}

variable "cribl_worker_port" {
  description = "Cribl worker port"
  type        = string
  default     = "4200"
}

variable "cribl_log_file" {
  description = "Cribl log file path"
  type        = string
  default     = "/var/log/cribl-init.log"
}

variable "cribl_dist_token" {
  description = "Cribl distributed env token"
  type        = string
  default     = "criblmaster"
}