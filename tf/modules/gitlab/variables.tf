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
      topics                     = set(string)
      visibility                 = string
      public_jobs                = bool
      protection_level           = string
      github_mirror              = bool
      enable_local_runner        = bool
      pages_unique_domain        = optional(bool)
      ci_pipeline_variables_role = optional(string)
    }))
  }))
}

variable "restricted_group_path" {
  type = string
}

variable "unrestricted_group_path" {
  type = string
}

variable "token_expires_at" {
  type = string
}

variable "ci_gitlab_token" {
  type      = string
  sensitive = true
  default   = ""
}

variable "ci_github_token" {
  type      = string
  sensitive = true
  default   = ""
}

variable "user_ssh_keys" {
  type = map(object({
    key        = string
    usage_type = optional(string, "auth")
  }))
  default = {}
}

variable "ssh_public_key" {
  type = string
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
