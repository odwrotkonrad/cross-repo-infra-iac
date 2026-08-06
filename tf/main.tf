##[>] 🤖🤖
locals {
  #[why] konradodwrot root stays declared but out of the plan until its state is adopted (manage_konradodwrot flips true).
  active_trees = {
    for k, t in var.trees : k => t
    if k != "konradodwrot" || var.manage_konradodwrot
  }

  #[why] per-root l0..l3 pyramids, then merged across roots. keys stay fully path-qualified so konradodwrot/* and restricted/* never collide and every state address is preserved.
  per_root = {
    for rk, tree in local.active_trees : rk => {
      l0_raw = {
        (tree.path) = {
          name        = tree.name
          leaf_path   = tree.path
          path        = tree.path
          description = tree.description
          projects    = tree.projects
          defaults    = tree.defaults
          raw         = tree
        }
      }
    }
  }

  l0_raw = merge([for rk, r in local.per_root : r.l0_raw]...)

  l1_raw = merge([
    for pk, pg in local.l0_raw : {
      for ck, cg in try(pg.raw.groups, {}) :
      "${pg.path}/${cg.path}" => {
        name        = cg.name
        leaf_path   = cg.path
        path        = "${pg.path}/${cg.path}"
        description = cg.description
        parent      = pg.path
        projects    = try(cg.projects, {})
        defaults    = try(cg.defaults, pg.defaults)
        raw         = cg
      }
    }
  ]...)

  l2_raw = merge([
    for pk, pg in local.l1_raw : {
      for ck, cg in try(pg.raw.groups, {}) :
      "${pg.path}/${cg.path}" => {
        name        = cg.name
        leaf_path   = cg.path
        path        = "${pg.path}/${cg.path}"
        description = cg.description
        parent      = pg.path
        projects    = try(cg.projects, {})
        defaults    = try(cg.defaults, pg.defaults)
        raw         = cg
      }
    }
  ]...)

  l3_raw = merge([
    for pk, pg in local.l2_raw : {
      for ck, cg in try(pg.raw.groups, {}) :
      "${pg.path}/${cg.path}" => {
        name        = cg.name
        leaf_path   = cg.path
        path        = "${pg.path}/${cg.path}"
        description = cg.description
        parent      = pg.path
        projects    = try(cg.projects, {})
        defaults    = try(cg.defaults, pg.defaults)
        raw         = cg
      }
    }
  ]...)

  levels = [
    for lvl in [local.l0_raw, local.l1_raw, local.l2_raw, local.l3_raw] : {
      groups = {
        for k, v in lvl : k => {
          name        = v.name
          leaf_path   = v.leaf_path
          description = v.description
          parent      = try(v.parent, null)
        }
      }
      projects = merge([
        for gk, g in lvl : {
          for pk, p in g.projects :
          "${g.path}/${p.path}" => {
            name                       = p.name
            path                       = p.path
            group                      = g.path
            description                = p.description
            allow_force_push           = try(p.allow_force_push, false)
            topics                     = try(p.topics, [])
            visibility                 = try(p.visibility, "public")
            public_jobs                = try(g.defaults.public_jobs, false)
            protection_level           = try(g.defaults.protection_level, "developer")
            github_mirror              = try(g.defaults.github_mirror, false)
            enable_local_runner        = try(p.enable_local_runner, false)
            pages_unique_domain        = try(p.pages_unique_domain, null)
            ci_pipeline_variables_role = try(p.ci_pipeline_variables_role, null)
          }
        }
      ]...)
    }
  ]

  #[why] mirror the github repos for every project that is push-mirrored (konradodwrot tree only, when active).
  github_repos = merge([
    for lvl in local.levels : {
      for k, p in lvl.projects : p.path => {
        description = p.description
        topics      = p.topics
        visibility  = p.visibility
      } if p.github_mirror
    }
  ]...)
}

module "github" {
  source = "./modules/github"

  github_repos = local.github_repos
}

module "gcp" {
  source = "./modules/gcp"

  gitlab_token    = module.gitlab.sandbox_token
  ssh_key_comment = var.sandbox_ssh_key_comment
}

module "gitlab" {
  source = "./modules/gitlab"

  levels                  = local.levels
  restricted_group_path   = "${var.trees["konradodwrot"].path}/restricted"
  unrestricted_group_path = "${var.trees["konradodwrot"].path}/unrestricted"
  token_expires_at        = var.token_expires_at
  ci_gitlab_token         = var.ci_gitlab_token
  ci_github_token         = var.ci_github_token
  user_ssh_keys           = var.user_ssh_keys
  ssh_public_key          = module.gcp.ssh_public_key
  local_runner_id         = var.local_runner_id
  github_owner            = var.github_owner
  github_token            = var.github_token

  depends_on = [module.github]
}
##[<] 🤖🤖
