output "asg_name" {
  value = aws_autoscaling_group.this.name
}

output "github_access_key_id" {
  value = aws_iam_access_key.github.id
}

output "github_secret_access_key" {
  value     = aws_iam_access_key.github.secret
  sensitive = true
}
