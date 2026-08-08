##[>] 🤖🤖
#[why] the provider's gitlab_user_sshkey has no usage_type: only auth keys are manageable here; signing keys go in via the REST api (POST /user/keys usage_type=signing)
resource "gitlab_user_sshkey" "this" {
  for_each = { for k, p in var.user_ssh_keys : k => p if p.usage_type == "auth" }

  title = each.key
  key   = each.value.key
}
##[<] 🤖🤖
