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
      job_token_allowlist        = optional(set(string), [])
    })), {})
    groups = optional(any, {})
  }))
}

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

variable "gcp_billing_account" {
  type      = string
  sensitive = true
}

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

#[why] repos whose CI mints semver tags, so consumers can pin a version: each gets a masked TAG_TOKEN
variable "tagging_projects" {
  type = list(string)
}

variable "ci_gitlab_token" {
  type      = string
  sensitive = true
}

variable "ci_google_credentials" {
  type      = string
  sensitive = true
}
##[<] 🤖🤖

##[>] 🤖🤖
variable "enable_darwin_ci" {
  type    = string
  default = "false"
}
##[<] 🤖🤖

##[>] 🤖🤖
#[what] the published che-packages catalog version every repo's CI pins to
#[why] empty means unset, which floats to latest: a local run wants current definitions, and only
#   CI, where this lands as CHE_PACKAGES_REF, needs an exactly reproducible one
variable "che_packages_ref" {
  type    = string
  default = ""
}
##[<] 🤖🤖

##[>] 🤖🤖
#[what] the value CI jobs assign to che's CHE_BACKUP_AUTO_CREATE when they opt out of archiving
#[why] false: every job remapping this runs che against a container or host thrown away with the
#   pipeline, where an archive protects nothing. only jobs that name it read it, so che's own
#   suites, which assert archiving happens, never see it
variable "che_backup_auto_create" {
  type    = string
  default = "false"
}
##[<] 🤖🤖

##[>] 🤖🤖
variable "ci_images_ref" {
  type    = string
  default = "latest"
}
##[<] 🤖🤖

##[>] 🤖🤖
variable "budget_amount" {
  type    = string
  default = "100"
}


variable "budget_alert_email" {
  type    = string
  default = "odwrotkonrad@gmail.com"
}

##[<] 🤖🤖

##[>] 🤖🤖
variable "ci_project_id" {
  type    = string
  default = "staging-499418"
}

variable "ci_project_name" {
  type    = string
  default = "staging"
}
##[<] 🤖🤖

##[>] 🤖🤖🤖
variable "prose_assets_ref" {
  type = string
}

variable "prose_spec_ref" {
  type = string
}

variable "misc_ref" {
  type = string
}
##[<] 🤖🤖🤖
