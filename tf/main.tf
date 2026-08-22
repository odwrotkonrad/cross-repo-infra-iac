##[>] 🤖🤖
locals {
  active_trees = {
    for k, t in var.trees : k => t
    if k != "konradodwrot" || var.manage_konradodwrot
  }

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
            job_token_allowlist        = [for t in try(p.job_token_allowlist, []) : "${split("/", g.path)[0]}/${t}"]
            github_repo                = replace(trimprefix("${g.path}/${p.path}", "${split("/", g.path)[0]}/"), "/", "-")
          }
        }
      ]...)
    }
  ]

  github_repos = merge([
    for lvl in local.levels : {
      for k, p in lvl.projects : p.github_repo => {
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
  control_project_path    = "${var.trees["konradodwrot"].path}/cross-repo/automation"
  automation_reviewer     = var.automation_reviewer
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
  quota_contact_email = var.budget_alert_email
  ci_images_ref       = var.CI_IMAGES_REF


  depends_on = [module.gcp]
}

module "gitlab" {
  source = "./modules/gitlab"

  levels           = local.levels
  iac_project_path = "${var.trees["konradodwrot"].path}/cross-repo/infra/iac"
  token_group_path = var.trees["konradodwrot"].path
  token_expires_at = var.token_expires_at
  tagging_projects = var.tagging_projects
  ci_gitlab_token  = var.ci_gitlab_token
  ENABLE_DARWIN_CI = var.ENABLE_DARWIN_CI
  CHE_PACKAGES_REF = var.CHE_PACKAGES_REF
  PROSE_ASSETS_REF = var.PROSE_ASSETS_REF
  PROSE_SPEC_REF   = var.PROSE_SPEC_REF
  MISC_REF         = var.MISC_REF
  CONFIGS_REF      = var.CONFIGS_REF
  AUTOMATION_REF   = var.AUTOMATION_REF
  IAC_REF          = var.IAC_REF

  CHE_BACKUP_AUTO_CREATE   = var.CHE_BACKUP_AUTO_CREATE
  CI_IMAGES_REF            = var.CI_IMAGES_REF
  ci_registry              = module.ci_cluster.ci_registry
  gitlab_registry_proxy    = module.ci_cluster.gitlab_registry_proxy
  dockerhub_registry_proxy = module.ci_cluster.dockerhub_registry_proxy
  go_proxy                 = module.ci_cluster.go_proxy

  ci_op_service_account_token = var.op_service_account_token
  ci_gcp_billing_account      = var.gcp_billing_account
  ci_google_credentials       = var.ci_google_credentials
  local_runner_id             = var.local_runner_id
  github_owner                = var.github_owner
  github_token                = var.github_token

  depends_on = [module.github]
}
##[<] 🤖🤖
