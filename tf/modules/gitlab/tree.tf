##[>] 🤖🤖
module "l0" {
  source = "./level"

  groups          = var.levels[0].groups
  projects        = var.levels[0].projects
  local_runner_id = var.local_runner_id
  github_owner    = var.github_owner
  github_token    = var.github_token
}

module "l1" {
  source = "./level"

  groups          = var.levels[1].groups
  projects        = var.levels[1].projects
  local_runner_id = var.local_runner_id
  parent_ids      = module.l0.group_ids
  github_owner    = var.github_owner
  github_token    = var.github_token
}

module "l2" {
  source = "./level"

  groups          = var.levels[2].groups
  projects        = var.levels[2].projects
  local_runner_id = var.local_runner_id
  parent_ids      = module.l1.group_ids
  github_owner    = var.github_owner
  github_token    = var.github_token
}

module "l3" {
  source = "./level"

  groups          = var.levels[3].groups
  projects        = var.levels[3].projects
  local_runner_id = var.local_runner_id
  parent_ids      = module.l2.group_ids
  github_owner    = var.github_owner
  github_token    = var.github_token
}

locals {
  project_ids = merge(
    module.l0.project_ids,
    module.l1.project_ids,
    module.l2.project_ids,
    module.l3.project_ids,
  )

  job_token_edges = {
    for e in flatten([
      for lvl in var.levels : [
        for k, p in lvl.projects : [
          for t in p.job_token_allowlist : { project = k, target = t }
        ]
      ]
    ]) : "${e.project}<-${e.target}" => e
  }
}

resource "gitlab_project_job_token_scope" "this" {
  for_each = local.job_token_edges

  project           = local.project_ids[each.value.project]
  target_project_id = local.project_ids[each.value.target]
}
##[<] 🤖🤖
