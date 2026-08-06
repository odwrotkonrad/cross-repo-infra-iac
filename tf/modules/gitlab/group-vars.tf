##[>] 🤖🤖
#[why] CI variables for the iac applier, on the iac project itself, protected: exposed only to
#   protected-ref pipelines (main), so a Developer-token branch push cannot read them.
#   masked: hidden in job logs. values come from sensitive TF_VAR_* inputs; empty -> variable
#   created empty + unmasked (GitLab rejects masked empty), populate in the UI. once a real
#   TF_VAR_* value is applied it is masked.
resource "gitlab_project_variable" "ci_gitlab_token" {
  project   = var.iac_project_path
  key       = "TF_GITLAB_TOKEN"
  value     = var.ci_gitlab_token
  masked    = var.ci_gitlab_token != ""
  protected = true
}

#[why] GOOGLE_CREDENTIALS is NOT managed here: it holds the out-of-band tf applier SA key
#   (created via gcloud, set via glab), kept outside the state this applier applies.

resource "gitlab_project_variable" "ci_github_token" {
  project   = var.iac_project_path
  key       = "GITHUB_TOKEN"
  value     = var.ci_github_token
  masked    = var.ci_github_token != ""
  protected = true
}
##[<] 🤖🤖
