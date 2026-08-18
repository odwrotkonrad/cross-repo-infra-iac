##[>] 🤖🤖
output "project_id" {
  value = google_project.auth.project_id
}

output "sa_email" {
  value = google_service_account.sandbox.email
}

output "ssh_signing_public_key" {
  value = tls_private_key.sandbox_signing.public_key_openssh
}

output "gitlab_token_secret" {
  value = google_secret_manager_secret.gitlab_token.secret_id
}

output "ssh_private_key_secret" {
  value = google_secret_manager_secret.ssh_private_key.secret_id
}

output "ssh_signing_key_secret" {
  value = google_secret_manager_secret.ssh_signing_key.secret_id
}

output "ssh_access_key_pub_secret" {
  value = google_secret_manager_secret.ssh_access_key_pub.secret_id
}

output "ssh_signing_key_pub_secret" {
  value = google_secret_manager_secret.ssh_signing_key_pub.secret_id
}
##[<] 🤖🤖
