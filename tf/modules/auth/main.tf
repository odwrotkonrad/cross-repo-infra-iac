##[>] 🤖🤖
module "sandbox" {
  source = "./sandbox"

  gcp_org_id          = var.gcp_org_id
  gcp_billing_account = var.gcp_billing_account
  project_id          = var.sandbox_auth_project_id
  gitlab_group_id     = var.gitlab_group_id
  token_expires_at    = var.token_expires_at
  ssh_key_comment     = var.ssh_key_comment
  op_vault            = var.op_vault
}

module "host" {
  source = "./host"

  user_ssh_keys = var.user_ssh_keys
}
##[<] 🤖🤖
