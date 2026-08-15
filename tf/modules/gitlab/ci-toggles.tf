##[>] 🤖🤖
#[why] group-level so one flip governs every repo's darwin jobs. unprotected and unmasked: it is a
#   behavior flag, not a secret, and MR-branch pipelines must read it to skip the macOS jobs
resource "gitlab_group_variable" "enable_darwin_ci" {
  group     = var.token_group_path
  key       = "ENABLE_DARWIN_CI"
  value     = var.enable_darwin_ci
  masked    = false
  protected = false
}
##[<] 🤖🤖
