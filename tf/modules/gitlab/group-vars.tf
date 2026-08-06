##[>] 🤖🤖
#[why] CI variables for the restricted applier, on the restricted group itself (module.l0 owns it).
#   masked: hidden in job logs. protected: exposed only to protected branches/tags (main).
#   values come from sensitive TF_VAR_* inputs; empty -> group variable created empty + unmasked (GitLab rejects masked empty), populate in the UI. once a real TF_VAR_* value is applied it is masked.
locals {
  restricted_group_id = module.l1.group_ids[var.restricted_group_path]
}

resource "gitlab_group_variable" "ci_gitlab_token" {
  group     = local.restricted_group_id
  key       = "TF_GITLAB_TOKEN"
  value     = var.ci_gitlab_token
  masked    = var.ci_gitlab_token != ""
  protected = false
}

#[why] GOOGLE_CREDENTIALS is NOT managed here: it holds the out-of-band tf-restricted-infra applier SA key (created via gcloud, set via glab), kept outside the state this applier applies. Same isolation as tf-git-repos.

resource "gitlab_group_variable" "ci_github_token" {
  group     = local.restricted_group_id
  key       = "GITHUB_TOKEN"
  value     = var.ci_github_token
  masked    = var.ci_github_token != ""
  protected = false
}
##[<] 🤖🤖
