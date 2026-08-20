##[>] 🤖🤖🤖
resource "gitlab_group_variable" "prose_ref" {
  group     = var.token_group_path
  key       = "GRP_KO_VAR_PROSE_REF"
  value     = var.prose_ref
  masked    = false
  protected = false
}
##[<] 🤖🤖🤖
