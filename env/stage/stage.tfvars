# Common variables
region  = "ap-south-1"
profile = "eksadmin"
tags = {
  Environment = "stage"
  Project     = "cribl"
  Owner       = "devops"
}

# VPC Configuration
name       = "cribl-stage-eks"
cidr_block = "20.0.0.0/16"

azs             = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
private_subnets = ["20.0.1.0/24", "20.0.2.0/24", "20.0.3.0/24"]
public_subnets  = ["20.0.101.0/24", "20.0.102.0/24", "20.0.103.0/24"]

enable_nat_gateway = true
single_nat_gateway = true

# EKS Configuration and Nodegroup
cluster_name            = "cribl-stage-eks"
kubernetes_version      = "1.33"
node_desired_size       = 2
node_min_size           = 1
node_max_size           = 3
node_instance_type      = "t3.medium"
node_disk_size          = 20
endpoint_private_access = true
endpoint_public_access  = true # false, only private API endpoint for production
ssh_key_name            = ""   # <-- replace with your EC2 key pair name

#EKS addons
vpc_cni_version    = null
coredns_version    = null
kube_proxy_version = null
ebs_csi_version    = null


# # RBAC Configuration
# namespace                = "cribl"
# create_service_account   = false
# service_account_name     = "cribl-stage-sa"
# service_account_role_arn = "arn:aws:iam::123456789012:role/cribl-stage-sa-role"
# admin_role_arn           = "arn:aws:iam::050451400963:user/tejas"

# admin_subjects = [
#   {
#     kind      = "User"
#     name      = "arn:aws:iam::050451400963:user/tejas"
#     api_group = "rbac.authorization.k8s.io"
#   }
# ]

# developer_subjects = [
#   {
#     kind      = "User"
#     name      = "arn:aws:iam::050451400963:user/app-dev1"
#     api_group = "rbac.authorization.k8s.io"
#   },
#   # {
#   #   kind      = "User"
#   #   name      = "arn:aws:iam::123456789012:user/app-dev2"
#   #   api_group = "rbac.authorization.k8s.io"
#   # }
# ]