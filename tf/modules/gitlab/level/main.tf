##[>] 🤖🤖
resource "gitlab_group" "this" {
  for_each = var.groups

  name             = each.value.name
  path             = each.value.leaf_path
  parent_id        = each.value.parent == null ? null : var.parent_ids[each.value.parent]
  description      = each.value.description
  visibility_level = "public"
}

resource "gitlab_project" "this" {
  for_each = var.projects

  namespace_id       = gitlab_group.this[each.value.group].id
  name               = each.value.name
  path               = each.value.path
  description        = each.value.description
  topics             = each.value.topics
  default_branch     = "main"
  visibility_level   = each.value.visibility
  pages_access_level = "enabled"
  public_jobs        = each.value.public_jobs

  container_registry_access_level = "disabled"

  auto_cancel_pending_pipelines = "enabled"

  ci_pipeline_variables_minimum_override_role = each.value.ci_pipeline_variables_role
}

resource "gitlab_branch_protection" "this" {
  for_each = var.projects

  project            = gitlab_project.this[each.key].id
  branch             = "main"
  push_access_level  = each.value.push_access_level
  merge_access_level = each.value.protection_level
  allow_force_push   = each.value.allow_force_push
}

resource "gitlab_branch_protection" "all" {
  for_each = { for k, p in var.projects : k => p if p.protect_all_branches }

  project            = gitlab_project.this[each.key].id
  branch             = "*"
  push_access_level  = "maintainer"
  merge_access_level = "maintainer"
  allow_force_push   = false
}

resource "gitlab_project_pages_settings" "this" {
  for_each = { for k, p in var.projects : k => p if p.pages_unique_domain != null }

  project                  = gitlab_project.this[each.key].id
  is_unique_domain_enabled = each.value.pages_unique_domain
}

resource "gitlab_project_runner_enablement" "local" {
  for_each = { for k, p in var.projects : k => p if p.enable_local_runner }

  project   = gitlab_project.this[each.key].id
  runner_id = var.local_runner_id
}

resource "gitlab_project_push_mirror" "github" {
  for_each = { for k, p in var.projects : k => p if p.github_mirror }

  project                 = gitlab_project.this[each.key].id
  url                     = "https://${var.github_owner}:${var.github_token}@github.com/${var.github_owner}/${each.value.github_repo}.git"
  auth_method             = "password"
  enabled                 = true
  only_protected_branches = true
  keep_divergent_refs     = false
}
##[<] 🤖🤖
