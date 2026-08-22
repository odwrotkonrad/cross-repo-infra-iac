##[>] 🤖🤖🤖
resource "gitlab_group_variable" "prose_assets_ref" {
  group     = var.token_group_path
  key       = "GRP_KO_VAR_PROSE_ASSETS_REF"
  value     = var.PROSE_ASSETS_REF
  masked    = false
  protected = false
}

resource "gitlab_group_variable" "prose_spec_ref" {
  group     = var.token_group_path
  key       = "GRP_KO_VAR_PROSE_SPEC_REF"
  value     = var.PROSE_SPEC_REF
  masked    = false
  protected = false
}

resource "gitlab_group_variable" "misc_ref" {
  group     = var.token_group_path
  key       = "GRP_KO_VAR_MISC_REF"
  value     = var.MISC_REF
  masked    = false
  protected = false
}

resource "gitlab_group_variable" "configs_ref" {
  group     = var.token_group_path
  key       = "GRP_KO_VAR_CONFIGS_REF"
  value     = var.CONFIGS_REF
  masked    = false
  protected = false
}

resource "gitlab_group_variable" "automation_ref" {
  group     = var.token_group_path
  key       = "GRP_KO_VAR_AUTOMATION_REF"
  value     = var.AUTOMATION_REF
  masked    = false
  protected = false
}

#[why] no tf/IAC_REF.auto.tfvars like its siblings: a checked-in pin of this repo would have to be
#   raised by the apply that publishes it. the tag-mint job runs before plan and passes the tag it
#   just minted as TF_VAR_IAC_REF, so the value is read at plan time instead of declared
resource "gitlab_group_variable" "iac_ref" {
  group     = var.token_group_path
  key       = "GRP_KO_VAR_IAC_REF"
  value     = var.IAC_REF
  masked    = false
  protected = false
}

##[<] 🤖🤖🤖
