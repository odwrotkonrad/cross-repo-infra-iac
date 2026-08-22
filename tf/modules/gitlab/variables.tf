##[>] 🤖🤖
variable "levels" {
  type = list(object({
    groups = map(object({
      name        = string
      leaf_path   = string
      description = string
      parent      = optional(string)
    }))
    projects = map(object({
      name                       = string
      path                       = string
      group                      = string
      description                = string
      allow_force_push           = bool
      push_access_level          = optional(string, "no one")
      topics                     = set(string)
      visibility                 = string
      public_jobs                = bool
      protection_level           = string
      github_mirror              = bool
      enable_local_runner        = bool
      pages_unique_domain        = optional(bool)
      ci_pipeline_variables_role = optional(string)
      protect_all_branches       = optional(bool, false)
      job_token_allowlist        = optional(set(string), [])
      github_repo                = string
    }))
  }))
}

variable "iac_project_path" {
  type = string
}

variable "ci_op_service_account_token" {
  type      = string
  sensitive = true
}

variable "ci_gcp_billing_account" {
  type      = string
  sensitive = true
}

variable "ci_google_credentials" {
  type      = string
  sensitive = true
}

variable "token_group_path" {
  type = string
}

variable "token_expires_at" {
  type = string
}

#[why] repo paths under token_group_path whose CI mints semver tags: each gets a masked TAG_TOKEN
variable "tagging_projects" {
  type = list(string)
}

variable "ci_gitlab_token" {
  type      = string
  sensitive = true
  default   = ""
}

variable "local_runner_id" {
  type    = number
  default = null
}

variable "github_owner" {
  type    = string
  default = null
}

variable "github_token" {
  type      = string
  sensitive = true
  default   = ""
}
##[<] 🤖🤖

##[>] 🤖🤖
variable "ENABLE_DARWIN_CI" {
  type    = string
  default = "false"
}
##[<] 🤖🤖

##[>] 🤖🤖
variable "CHE_PACKAGES_REF" {
  type    = string
  default = ""
}
##[<] 🤖🤖

##[>] 🤖🤖
variable "CHE_BACKUP_AUTO_CREATE" {
  type    = string
  default = "false"
}
##[<] 🤖🤖

##[>] 🤖🤖
variable "CI_IMAGES_REF" {
  type = string
}

variable "ci_registry" {
  type = string
}

variable "gitlab_registry_proxy" {
  type = string
}

variable "dockerhub_registry_proxy" {
  type = string
}

variable "go_proxy" {
  type = string
}
##[<] 🤖🤖

##[>] 🤖🤖🤖
variable "PROSE_ASSETS_REF" {
  type = string
}

variable "PROSE_SPEC_REF" {
  type = string
}

variable "MISC_REF" {
  type = string
}

variable "CONFIGS_REF" {
  type = string
}

variable "AUTOMATION_REF" {
  type = string
}

variable "iac_ref" {
  type = string
}
##[<] 🤖🤖🤖
