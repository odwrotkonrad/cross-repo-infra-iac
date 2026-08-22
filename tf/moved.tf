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

moved {
  from = module.gitlab.module.l1.gitlab_group.this["konradodwrot/infra"]
  to   = module.gitlab.module.l2.gitlab_group.this["konradodwrot/cross-repo/infra"]
}

moved {
  from = module.gitlab.module.l0.gitlab_project.this["konradodwrot/control"]
  to   = module.gitlab.module.l1.gitlab_project.this["konradodwrot/cross-repo/automation"]
}

moved {
  from = module.gitlab.module.l0.gitlab_branch_protection.this["konradodwrot/control"]
  to   = module.gitlab.module.l1.gitlab_branch_protection.this["konradodwrot/cross-repo/automation"]
}

moved {
  from = module.gitlab.module.l0.gitlab_project_push_mirror.github["konradodwrot/control"]
  to   = module.gitlab.module.l1.gitlab_project_push_mirror.github["konradodwrot/cross-repo/automation"]
}

moved {
  from = module.gitlab.module.l0.gitlab_project.this["konradodwrot/prose"]
  to   = module.gitlab.module.l2.gitlab_project.this["konradodwrot/cross-repo/prose/assets"]
}

moved {
  from = module.gitlab.module.l0.gitlab_branch_protection.this["konradodwrot/prose"]
  to   = module.gitlab.module.l2.gitlab_branch_protection.this["konradodwrot/cross-repo/prose/assets"]
}

moved {
  from = module.gitlab.module.l0.gitlab_project_push_mirror.github["konradodwrot/prose"]
  to   = module.gitlab.module.l2.gitlab_project_push_mirror.github["konradodwrot/cross-repo/prose/assets"]
}

moved {
  from = module.gitlab.module.l1.gitlab_project.this["konradodwrot/infra/iac"]
  to   = module.gitlab.module.l2.gitlab_project.this["konradodwrot/cross-repo/infra/iac"]
}

moved {
  from = module.gitlab.module.l1.gitlab_branch_protection.this["konradodwrot/infra/iac"]
  to   = module.gitlab.module.l2.gitlab_branch_protection.this["konradodwrot/cross-repo/infra/iac"]
}

moved {
  from = module.gitlab.module.l1.gitlab_branch_protection.all["konradodwrot/infra/iac"]
  to   = module.gitlab.module.l2.gitlab_branch_protection.all["konradodwrot/cross-repo/infra/iac"]
}

moved {
  from = module.gitlab.module.l1.gitlab_project_push_mirror.github["konradodwrot/infra/iac"]
  to   = module.gitlab.module.l2.gitlab_project_push_mirror.github["konradodwrot/cross-repo/infra/iac"]
}

moved {
  from = module.gitlab.module.l1.gitlab_project.this["konradodwrot/infra/oci-images"]
  to   = module.gitlab.module.l2.gitlab_project.this["konradodwrot/cross-repo/infra/oci-images"]
}

moved {
  from = module.gitlab.module.l1.gitlab_branch_protection.this["konradodwrot/infra/oci-images"]
  to   = module.gitlab.module.l2.gitlab_branch_protection.this["konradodwrot/cross-repo/infra/oci-images"]
}

moved {
  from = module.gitlab.module.l1.gitlab_project_runner_enablement.local["konradodwrot/infra/oci-images"]
  to   = module.gitlab.module.l2.gitlab_project_runner_enablement.local["konradodwrot/cross-repo/infra/oci-images"]
}

moved {
  from = module.gitlab.module.l1.gitlab_project_push_mirror.github["konradodwrot/infra/oci-images"]
  to   = module.gitlab.module.l2.gitlab_project_push_mirror.github["konradodwrot/cross-repo/infra/oci-images"]
}

moved {
  from = module.gitlab.module.l1.gitlab_project.this["konradodwrot/infra/sandbox"]
  to   = module.gitlab.module.l0.gitlab_project.this["konradodwrot/ai-sandbox"]
}

moved {
  from = module.gitlab.module.l1.gitlab_branch_protection.this["konradodwrot/infra/sandbox"]
  to   = module.gitlab.module.l0.gitlab_branch_protection.this["konradodwrot/ai-sandbox"]
}

moved {
  from = module.gitlab.module.l1.gitlab_project_push_mirror.github["konradodwrot/infra/sandbox"]
  to   = module.gitlab.module.l0.gitlab_project_push_mirror.github["konradodwrot/ai-sandbox"]
}

moved {
  from = module.gitlab.module.l0.gitlab_project_job_token_scope.this["konradodwrot/control<-konradodwrot/prose"]
  to   = module.gitlab.gitlab_project_job_token_scope.this["konradodwrot/cross-repo/automation<-konradodwrot/cross-repo/prose/assets"]
}

moved {
  from = module.gitlab.gitlab_project_variable.tag_token["prose"]
  to   = module.gitlab.gitlab_project_variable.tag_token["cross-repo/prose/assets"]
}

moved {
  from = module.gitlab.gitlab_project_variable.tag_token["control"]
  to   = module.gitlab.gitlab_project_variable.tag_token["cross-repo/automation"]
}

moved {
  from = module.github.github_repository.this["sandbox"]
  to   = module.github.github_repository.this["ai-sandbox"]
}

moved {
  from = module.github.github_repository.this["control"]
  to   = module.github.github_repository.this["cross-repo-automation"]
}

moved {
  from = module.github.github_repository.this["prose"]
  to   = module.github.github_repository.this["cross-repo-prose-assets"]
}

moved {
  from = module.github.github_repository.this["iac"]
  to   = module.github.github_repository.this["cross-repo-infra-iac"]
}

moved {
  from = module.github.github_repository.this["oci-images"]
  to   = module.github.github_repository.this["cross-repo-infra-oci-images"]
}

moved {
  from = module.auth.module.control
  to   = module.auth.module.automation
}

moved {
  from = module.auth.module.automation.gitlab_group_access_token.control
  to   = module.auth.module.automation.gitlab_group_access_token.automation
}

moved {
  from = module.auth.module.automation.gitlab_project_variable.control_gitlab_token
  to   = module.auth.module.automation.gitlab_project_variable.control_gitlab_token_compat
}

##[<] 🤖🤖
