output "github_access_key_id" {
  value = module.compute.github_access_key_id
}

output "github_secret_access_key" {
  value     = module.compute.github_secret_access_key
  sensitive = true
}
