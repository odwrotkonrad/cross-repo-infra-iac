##[>] 🤖🤖
output "sandbox_auth_project_id" {
  value = module.auth.project_id
}

output "sandbox_sa_email" {
  value = module.auth.sa_email
}

output "gitlab_token_secret" {
  value = module.auth.gitlab_token_secret
}

output "ssh_private_key_secret" {
  value = module.auth.ssh_private_key_secret
}

output "ssh_signing_key_secret" {
  value = module.auth.ssh_signing_key_secret
}

output "ssh_access_key_pub_secret" {
  value = module.auth.ssh_access_key_pub_secret
}

output "ssh_signing_key_pub_secret" {
  value = module.auth.ssh_signing_key_pub_secret
}

output "ssh_signing_public_key" {
  value = module.auth.ssh_signing_public_key
}
##[<] 🤖🤖
