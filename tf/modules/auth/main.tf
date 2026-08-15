##[>] 🤖🤖
module "sandbox" {
  source = "./sandbox"

  sandbox_folder_id   = var.sandbox_folder_id
  dev_folder_name     = var.dev_folder_name
  gcp_billing_account = var.gcp_billing_account
  project_id          = var.sandbox_auth_project_id
  gitlab_group_id     = var.gitlab_group_id
  token_expires_at    = var.token_expires_at
  ssh_key_comment     = var.ssh_key_comment
  op_vault            = var.op_vault
  ci_member           = var.ci_member
}

module "release_signing" {
  source = "./release-signing"

  op_vault                = var.op_vault
  go_modules_project_path = var.go_modules_project_path
  gpg_name                = var.apt_gpg_name
  gpg_email               = var.apt_gpg_email
}

module "control" {
  source = "./control"

  gitlab_group_id      = var.gitlab_group_id
  token_expires_at     = var.token_expires_at
  gcp_project_id       = module.sandbox.project_id
  control_project_path = var.control_project_path
}

module "host" {
  source = "./host"

  user_ssh_keys = var.user_ssh_keys
}
##[<] 🤖🤖
