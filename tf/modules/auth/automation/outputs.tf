##[>] 🤖🤖
output "gitlab_token_secret" {
  value = google_secret_manager_secret.automation_gitlab_token.secret_id
}
##[<] 🤖🤖
