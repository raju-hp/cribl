variable "region" {
  description = "AWS region"
  type        = string
  default     = ""
}
variable "profile" {
  description = "AWS profile"
  type        = string
  default     = "eksadmin"
}
variable "environment" {}

variable "vpc_cidr" {}
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "availability_zones" { type = list(string) }

variable "leader_instance_type" {}
variable "leader_min_max" { type = list(number) }
variable "leader_desired_count" {}

variable "worker_instance_type" {}
variable "worker_min_max" { type = list(number) }
variable "worker_desired_count" {}


variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Project     = "Cribl"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

variable "key_name" {
  description = "SSH key pair name to access EC2 instances"
  type        = string
  default     = "cribl-key"
}

variable "cribl_leader_ami" {
  description = "AMI ID for Cribl leader instance"
  type        = string
  default     = "ami-0abcdef1234567890" # replace with your region AMI
}


variable "name" {
  description = "Project name or environment name"
  type        = string
}

variable "cribl_version" {
  description = "Version of Cribl to install"
  type        = string
  default     = "4.7.0"
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