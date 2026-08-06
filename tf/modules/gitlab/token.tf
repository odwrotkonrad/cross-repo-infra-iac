##[>] 🤖🤖
resource "gitlab_group_access_token" "sandbox" {
  group        = module.l1.group_ids[var.unrestricted_group_path]
  name         = "sandbox-rw-nodelete"
  scopes       = ["api", "write_repository", "read_repository"]
  access_level = "developer"
  expires_at   = var.token_expires_at
}
##[<] 🤖🤖
