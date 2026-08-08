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

variable "sandbox_auth_project_id" {
  type = string
}

variable "gitlab_group_id" {
  type = string
}

variable "token_expires_at" {
  type = string
}

variable "ssh_key_comment" {
  type = string
}

variable "op_vault" {
  type = string
}

variable "go_modules_project_path" {
  type = string
}

variable "ci_member" {
  type = string
}

variable "apt_gpg_name" {
  type = string
}

variable "apt_gpg_email" {
  type = string
}

variable "user_ssh_keys" {
  type = map(object({
    key        = string
    usage_type = optional(string, "auth")
  }))
  default = {}
}
##[<] 🤖🤖
