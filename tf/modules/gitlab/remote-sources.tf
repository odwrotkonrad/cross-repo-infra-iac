##[>] 🤖🤖
#[why] che fetches the prose and configs repos as remote sources during a sync, and a job doing so
#   needs a credential: the group's repos are not all public. read-only at reporter, the weakest
#   role that can clone, because a fetch never writes
resource "gitlab_group_access_token" "remote_sources" {
  group        = module.l0.group_ids[var.token_group_path]
  name         = "remote-sources-reader"
  scopes       = ["read_api", "read_repository"]
  access_level = "reporter"
  expires_at   = var.token_expires_at
}

#[why] a group variable, unlike the tagger's per-project one: every repo whose CI renders templates
#   from prose needs it, and the token can only read
resource "gitlab_group_variable" "gitlab_token" {
  group     = var.token_group_path
  key       = "GRP_KO_VAR_GITLAB_TOKEN"
  value     = gitlab_group_access_token.remote_sources.token
  masked    = true
  protected = false
}
##[<] 🤖🤖
