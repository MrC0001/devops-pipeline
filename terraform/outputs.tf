output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.application.id
}

output "public_ip" {
  description = "Public IP used by Ansible."
  value       = aws_instance.application.public_ip
}

output "application_url" {
  description = "Public URL for the app."
  value       = "http://${aws_instance.application.public_ip}"
}
