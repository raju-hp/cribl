output "leader_id" {
  value = aws_instance.leader.id
}

output "leader_private_ip" {
  description = "Private IP address of the Cribl leader instance"
  value       = aws_instance.leader.private_ip
}
