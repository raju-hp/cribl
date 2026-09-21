output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "leader_target_group_arn" {
  description = "ARN of the Leader target group"
  value       = aws_lb_target_group.leader.arn
}

output "worker_target_group_arn" {
  description = "ARN of the Worker target group"
  value       = aws_lb_target_group.worker.arn
}
