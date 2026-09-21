variable "name" {
  description = "Name prefix for ALB and related resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the ALB"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets (typically public) where ALB should be deployed"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups to associate with ALB"
  type        = list(string)
}

variable "tags" {
  description = "Common tags for ALB resources"
  type        = map(string)
  default     = {}
}

variable "leader_instance_id" {
  description = "The ID of the Cribl Leader EC2 instance to attach to the leader target group"
  type        = string
}

variable "worker_asg_name" {
  description = "The name of the Cribl Worker Auto Scaling Group to attach to the worker target group"
  type        = string
}


