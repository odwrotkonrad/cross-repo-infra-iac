##[>] 🤖🤖
variable "trees" {
  type = map(object({
    name        = string
    path        = string
    description = string
    defaults = optional(object({
      public_jobs      = optional(bool, false)
      protection_level = optional(string, "developer")
      github_mirror    = optional(bool, false)
    }), {})
    projects = optional(map(object({
      name                       = string
      path                       = string
      description                = string
      allow_force_push           = optional(bool, false)
      push_access_level          = optional(string, "no one")
      topics                     = optional(set(string), [])
      visibility                 = optional(string, "public")
      enable_local_runner        = optional(bool, false)
      pages_unique_domain        = optional(bool)
      ci_pipeline_variables_role = optional(string)
    })), {})
    groups = optional(any, {})
  }))
}

#[why] gate the konradodwrot root: false keeps it declared but out of the plan while git-repos still owns it in its own state; flip true after state adoption.
variable "manage_konradodwrot" {
  type    = bool
  default = false
}

variable "local_runner_id" {
  type    = number
  default = null
}

variable "user_ssh_keys" {
  type = map(object({
    key        = string
    usage_type = optional(string, "auth")
  }))
  default = {}
}

variable "github_owner" {
  type    = string
  default = null
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "gcp_project" {
  type    = string
  default = "main-493613"
}

variable "gcp_applier_member" {
  type    = string
  default = "user:odwrotkonrad@gmail.com"
}

variable "gcp_ci_member" {
  type    = string
  default = "serviceAccount:tf-restricted-infra@main-493613.iam.gserviceaccount.com"
}

variable "gcp_org_id" {
  type    = string
  default = "882523005777"
}

#[why] set via TF_VAR_gcp_billing_account at plan/apply, never committed
variable "gcp_billing_account" {
  type      = string
  sensitive = true
}

#[why] 1P service account scoped write to the sandbox vault only: set via TF_VAR_op_service_account_token (or OP_SERVICE_ACCOUNT_TOKEN) at plan/apply
variable "op_service_account_token" {
  type      = string
  sensitive = true
}

variable "op_vault" {
  type    = string
  default = "SandboxProgrammaticAccess"
}

variable "sandbox_auth_project_id" {
  type    = string
  default = "konradodwrot-sandbox-auth"
}

variable "sandbox_ssh_key_comment" {
  type    = string
  default = "odwrotkonrad+sandbox@gmail.com"
}

variable "apt_gpg_name" {
  type    = string
  default = "konradodwrot apt"
}

variable "apt_gpg_email" {
  type    = string
  default = "odwrotkonrad+apt@gmail.com"
}


variable "token_expires_at" {
  type = string
}

#[why] required, no empty default: an apply without TF_VAR_ci_gitlab_token would blank the CI variable. restricted CI's own gitlab token, NOT the sandbox token
variable "ci_gitlab_token" {
  type      = string
  sensitive = true
}

#[why] required, no empty default: an apply without TF_VAR_ci_google_credentials would blank the CI variable. base64 SA key of the CI applier
variable "ci_google_credentials" {
  type      = string
  sensitive = true
}
##[<] 🤖🤖

##[>] 🤖🤖
#[why] group-level darwin CI toggle: "true" runs the macOS jobs, anything else skips them
variable "enable_darwin_ci" {
  type    = string
  default = "false"
}
##[<] 🤖🤖

##[>] 🤖🤖
#[why] total-spend budget on the billing account: warn at half, critical at the amount, plus a forecast rule
variable "budget_amount" {
  type    = string
  default = "100"
}

variable "budget_currency" {
  type    = string
  default = "USD"
}

variable "budget_alert_email" {
  type    = string
  default = "odwrotkonrad@gmail.com"
}

#[why] empty skips the sms channel; set it and verify the number in the console once
variable "budget_alert_sms" {
  type    = string
  default = ""
}
##[<] 🤖🤖

##[>] 🤖🤖
#[why] own project for the CI cluster: spend reads as one figure per project in billing reports
variable "ci_project_id" {
  type    = string
  default = "konradodwrot-ci"
}
##[<] 🤖🤖
