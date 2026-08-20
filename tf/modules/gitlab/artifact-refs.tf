##[>] 🤖🤖🤖
resource "gitlab_group_variable" "prose_assets_ref" {
  group     = var.token_group_path
  key       = "GRP_KO_VAR_PROSE_ASSETS_REF"
  value     = var.prose_assets_ref
  masked    = false
  protected = false
}

resource "gitlab_group_variable" "prose_spec_ref" {
  group     = var.token_group_path
  key       = "GRP_KO_VAR_PROSE_SPEC_REF"
  value     = var.prose_spec_ref
  masked    = false
  protected = false
}

resource "gitlab_group_variable" "misc_ref" {
  group     = var.token_group_path
  key       = "GRP_KO_VAR_MISC_REF"
  value     = var.misc_ref
  masked    = false
  protected = false
}

resource "gitlab_group_variable" "prose_ref_legacy" {
  group     = var.token_group_path
  key       = "GRP_KO_VAR_PROSE_REF"
  value     = var.prose_assets_ref
  masked    = false
  protected = false
}
##[<] 🤖🤖🤖
