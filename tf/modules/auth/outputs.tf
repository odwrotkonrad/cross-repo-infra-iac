##[>] 🤖🤖
output "project_id" {
  value = module.sandbox.project_id
}

output "sa_email" {
  value = module.sandbox.sa_email
}

output "gitlab_token_secret" {
  value = module.sandbox.gitlab_token_secret
}

output "ssh_private_key_secret" {
  value = module.sandbox.ssh_private_key_secret
}

output "ssh_signing_key_secret" {
  value = module.sandbox.ssh_signing_key_secret
}

output "ssh_access_key_pub_secret" {
  value = module.sandbox.ssh_access_key_pub_secret
}

output "ssh_signing_key_pub_secret" {
  value = module.sandbox.ssh_signing_key_pub_secret
}

output "ssh_signing_public_key" {
  value = module.sandbox.ssh_signing_public_key
}

output "control_gitlab_token_secret" {
  value = module.control.gitlab_token_secret
}
##[<] 🤖🤖
