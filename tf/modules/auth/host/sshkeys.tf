##[>] 🤖🤖
resource "gitlab_user_sshkey" "this" {
  for_each = { for k, p in var.user_ssh_keys : k => p if p.usage_type == "auth" }

  title = each.key
  key   = each.value.key
}
##[<] 🤖🤖
