##[>] 🤖🤖
resource "gitlab_group_access_token" "sandbox" {
  group        = var.gitlab_group_id
  name         = "sandbox-rw-nodelete"
  scopes       = ["api", "write_repository", "read_repository"]
  access_level = "developer"
  expires_at   = var.token_expires_at
}

resource "gitlab_user_sshkey" "sandbox" {
  title = "sandbox-shared"
  key   = tls_private_key.sandbox.public_key_openssh
}
##[<] 🤖🤖
