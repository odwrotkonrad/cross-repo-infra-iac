##[>] 🤖🤖
variable "sandbox_folder_id" {
  type = string
}

variable "dev_folder_name" {
  type = string
}

variable "gcp_billing_account" {
  type      = string
  sensitive = true
}

variable "project_id" {
  type = string
}

variable "gitlab_group_id" {
  type = string
}

variable "token_expires_at" {
  type = string
}

#[why] trailing comment on the sandbox .pub keys (ssh-keygen comment slot); shows in ssh-add -l, agent, signed-commit key display
variable "ssh_key_comment" {
  type = string
}

variable "op_vault" {
  type = string
}

variable "ci_member" {
  type = string
}
##[<] 🤖🤖
