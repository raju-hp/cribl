output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnets" {
  description = "Public subnets for ALB"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "Private subnets for EC2 nodes"
  value       = aws_subnet.private[*].id
}

output "alb_sg_id" {
  description = "Security group ID for ALB"
  value       = aws_security_group.alb_sg.id
}

output "leader_sg_id" {
  description = "Security group ID for Leader"
  value       = aws_security_group.leader_sg.id
}

output "worker_sg_id" {
  description = "Security group ID for Worker"
  value       = aws_security_group.worker_sg.id
}

output "default_sg_id" {
  description = "Default security group ID of the VPC"
  value       = aws_vpc.this.default_security_group_id
}