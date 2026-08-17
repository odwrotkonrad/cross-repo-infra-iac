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
            push_access_level          = try(p.push_access_level, "no one")
            topics                     = try(p.topics, [])
            visibility                 = try(p.visibility, "public")
            public_jobs                = try(g.defaults.public_jobs, false)
            protection_level           = try(g.defaults.protection_level, "developer")
            github_mirror              = try(g.defaults.github_mirror, false)
            enable_local_runner        = try(p.enable_local_runner, false)
            pages_unique_domain        = try(p.pages_unique_domain, null)
            ci_pipeline_variables_role = try(p.ci_pipeline_variables_role, null)
            protect_all_branches       = try(p.protect_all_branches, false)
            job_token_allowlist        = [for t in try(p.job_token_allowlist, []) : "${g.path}/${t}"]
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

  gcp_org_id         = var.gcp_org_id
  gcp_project        = var.gcp_project
  gcp_applier_member = var.gcp_applier_member
  gcp_ci_member      = var.gcp_ci_member

  gcp_billing_account = var.gcp_billing_account
  budget_amount       = var.budget_amount
  budget_alert_email  = var.budget_alert_email
}

module "auth" {
  source = "./modules/auth"

  sandbox_folder_id       = module.gcp.sandbox_folder_id
  dev_folder_name         = module.gcp.dev_folder_name
  gcp_billing_account     = var.gcp_billing_account
  sandbox_auth_project_id = var.sandbox_auth_project_id
  gitlab_group_id         = module.gitlab.group_ids[var.trees["konradodwrot"].path]
  token_expires_at        = var.token_expires_at
  ssh_key_comment         = var.sandbox_ssh_key_comment
  op_vault                = var.op_vault
  ci_member               = var.gcp_ci_member
  go_modules_project_path = "${var.trees["konradodwrot"].path}/go-modules"
  control_project_path    = "${var.trees["konradodwrot"].path}/control"
  apt_gpg_name            = var.apt_gpg_name
  apt_gpg_email           = var.apt_gpg_email
  user_ssh_keys           = var.user_ssh_keys
}

module "ci_cluster" {
  source = "./modules/ci-cluster"

  project_id          = var.ci_project_id
  project_name        = var.ci_project_name
  gcp_org_id          = var.gcp_org_id
  gcp_billing_account = var.gcp_billing_account
  gcp_ci_member       = var.gcp_ci_member
  gitlab_group_id     = module.gitlab.group_ids[var.trees["konradodwrot"].path]
  #[why] the same address the budget alerts go to: one place owns where infrastructure mail lands
  quota_contact_email = var.budget_alert_email

  #[why] the quota preference this module creates is checked against the provider's quota project, so
  #   it needs modules/gcp's cloudquotas service enabled first. nothing here references that resource,
  #   so without this edge terraform is free to run them concurrently and fail on "api has not been
  #   used in project"
  depends_on = [module.gcp]
}

module "gitlab" {
  source = "./modules/gitlab"

  levels           = local.levels
  iac_project_path = "${var.trees["konradodwrot"].path}/infra/iac"
  token_group_path = var.trees["konradodwrot"].path
  token_expires_at = var.token_expires_at
  ci_gitlab_token  = var.ci_gitlab_token
  enable_darwin_ci = var.enable_darwin_ci

  ci_op_service_account_token = var.op_service_account_token
  ci_gcp_billing_account      = var.gcp_billing_account
  ci_google_credentials       = var.ci_google_credentials
  local_runner_id             = var.local_runner_id
  github_owner                = var.github_owner
  github_token                = var.github_token

  depends_on = [module.github]
}
##[<] 🤖🤖
