##[>] 🤖🤖
variable "groups" {
  type = map(object({
    name        = string
    leaf_path   = string
    description = string
    parent      = optional(string)
  }))
}

variable "projects" {
  type = map(object({
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
  }))
}

variable "local_runner_id" {
  type    = number
  default = null
}

variable "parent_ids" {
  type    = map(string)
  default = {}
}

variable "github_owner" {
  type    = string
  default = null
}

variable "github_token" {
  type      = string
  sensitive = true
  default   = null
}
##[<] 🤖🤖
