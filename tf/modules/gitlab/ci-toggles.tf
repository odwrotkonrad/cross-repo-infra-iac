##[>] 🤖🤖
resource "gitlab_group_variable" "enable_darwin_ci" {
  group     = var.token_group_path
  key       = "ENABLE_DARWIN_CI"
  value     = var.enable_darwin_ci
  masked    = false
  protected = false
}
##[<] 🤖🤖
