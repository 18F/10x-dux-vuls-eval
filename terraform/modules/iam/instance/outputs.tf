output "name" {
  description = "The name of instance profile created"
  value       = aws_iam_instance_profile.profile.name
}