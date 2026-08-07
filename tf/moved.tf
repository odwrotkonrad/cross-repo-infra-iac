##[>] 🤖🤖
moved {
  from = gitlab_group_access_token.sandbox
  to   = module.gitlab.gitlab_group_access_token.sandbox
}

moved {
  from = gitlab_group_variable.ci_gitlab_token
  to   = module.gitlab.gitlab_group_variable.ci_gitlab_token
}

moved {
  from = gitlab_group_variable.ci_github_token
  to   = module.gitlab.gitlab_group_variable.ci_github_token
}

moved {
  from = gitlab_user_sshkey.sandbox
  to   = module.gitlab.gitlab_user_sshkey.sandbox
}

moved {
  from = gitlab_user_sshkey.this
  to   = module.gitlab.gitlab_user_sshkey.this
}

moved {
  from = module.l0
  to   = module.gitlab.module.l0
}

moved {
  from = module.l1
  to   = module.gitlab.module.l1
}

moved {
  from = module.l2
  to   = module.gitlab.module.l2
}

moved {
  from = module.l3
  to   = module.gitlab.module.l3
}

moved {
  from = tls_private_key.sandbox
  to   = module.gcp.tls_private_key.sandbox
}

moved {
  from = module.gcp.tls_private_key.sandbox
  to   = module.auth.module.sandbox.tls_private_key.sandbox
}

moved {
  from = module.gcp.tls_private_key.sandbox_signing
  to   = module.auth.module.sandbox.tls_private_key.sandbox_signing
}

moved {
  from = module.gitlab.gitlab_group_access_token.sandbox
  to   = module.auth.module.sandbox.gitlab_group_access_token.sandbox
}

moved {
  from = module.gitlab.gitlab_user_sshkey.sandbox
  to   = module.auth.module.sandbox.gitlab_user_sshkey.sandbox
}

moved {
  from = module.gitlab.gitlab_user_sshkey.this
  to   = module.auth.module.host.gitlab_user_sshkey.this
}

moved {
  from = module.auth.module.sandbox.google_folder.sandbox
  to   = module.gcp.google_folder.sandbox
}

moved {
  from = module.auth.module.sandbox.google_folder.dev
  to   = module.gcp.google_folder.dev
}
##[<] 🤖🤖
