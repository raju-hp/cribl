#Common variable values
region      = "us-east-1"
name        = "cribl-dev"
environment = "dev"
tags = {
  Environment = "dev"
  Project     = "cribl"
  ManagedBy   = "terraform"
}

# VPC variable values
vpc_cidr           = "10.0.0.0/16"
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets    = ["10.0.10.0/24", "10.0.20.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]


# Cribl-common variable values
cribl_version     = "4.7.0"
cribl_dir         = "/opt/cribl"
cribl_worker_port = "4200"
cribl_log_file    = "/var/log/cribl-init.log"
cribl_dist_token  = "criblmaster"
key_name          = "devops-us-east-1"


# Cribl-leader variable values
leader_instance_type = "t2.medium"
leader_min_max       = [1, 2]
leader_desired_count = 1


# Cribl-worker variable values
worker_instance_type = "t2.medium"
worker_min_max       = [1, 2]
worker_desired_count = 2


