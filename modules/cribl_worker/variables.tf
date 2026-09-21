variable "name" {
  type        = string
  description = "Name prefix for Cribl worker"
}

variable "instance_type" {
  type        = string
  description = "Instance type for worker node"
}

variable "instance_profile" {
  type        = string
  description = "IAM instance profile name for worker node"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs"
}

variable "security_groups" {
  type        = list(string)
  description = "Security groups for worker nodes"
}

variable "desired_count" {
  type        = number
  description = "Desired number of worker nodes"
}

variable "alb_target_group_arn" {
  type        = string
  description = "Target group ARN for worker nodes"
}

variable "tags" {
  type        = map(string)
  description = "Common tags"
}

variable "worker_min_max" {
  type        = list(number)
  description = "Min and max worker node count"
}

variable "leader_leader_ip" {
  description = "Leader private ip address"
  type        = string
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