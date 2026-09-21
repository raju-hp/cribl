output "leader_profile" {
  description = "IAM instance profile name for Cribl Leader"
  value       = aws_iam_instance_profile.leader_profile.name
}

output "worker_profile" {
  description = "IAM instance profile name for Cribl Worker"
  value       = aws_iam_instance_profile.worker_profile.name
}
