# VPC Module
module "vpc" {
  source             = "./modules/vpc"
  name               = var.name
  cidr_block         = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones

  tags = {
    Environment = var.environment
    Project     = "cribl"
  }
}

# IAM Roles for Cribl
module "iam" {
  source             = "./modules/iam"
  project            = var.name
  enable_s3_access   = true
  s3_allowed_buckets = ["arn:aws:s3:::cribl-artifacts", "arn:aws:s3:::cribl-storage"]
  tags               = var.tags

  depends_on = [module.vpc]
}


# Application Load Balancer
module "alb" {
  source             = "./modules/alb"
  name               = var.name
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnets
  security_group_ids = [module.vpc.alb_sg_id]
  leader_instance_id = module.cribl_leader.leader_id
  worker_asg_name    = module.cribl_worker.asg_name
  tags               = var.tags
}





# Crible leader
module "cribl_leader" {
  source            = "./modules/cribl_leader"
  name              = "${var.name}-leader"
  instance_type     = var.leader_instance_type
  instance_profile  = module.iam.leader_profile
  subnet_ids        = module.vpc.private_subnets
  security_groups   = [module.vpc.leader_sg_id]
  cribl_dir         = var.cribl_dir
  cribl_worker_port = var.cribl_worker_port
  cribl_log_file    = var.cribl_log_file
  cribl_dist_token  = var.cribl_dist_token
  key_name          = var.key_name
  tags              = var.tags

  depends_on = [module.iam]
}

# Cribl worker
module "cribl_worker" {
  source               = "./modules/cribl_worker"
  name                 = "${var.name}-worker"
  instance_type        = var.worker_instance_type
  instance_profile     = module.iam.worker_profile
  subnet_ids           = module.vpc.private_subnets
  security_groups      = [module.vpc.default_sg_id]
  desired_count        = var.worker_desired_count
  worker_min_max       = var.worker_min_max
  leader_leader_ip     = module.cribl_leader.leader_private_ip
  cribl_dir            = var.cribl_dir
  cribl_worker_port    = var.cribl_worker_port
  cribl_log_file       = var.cribl_log_file
  cribl_dist_token     = var.cribl_dist_token
  alb_target_group_arn = module.alb.worker_target_group_arn
  tags                 = var.tags

  depends_on = [module.cribl_leader]
}

# Cribal common variables