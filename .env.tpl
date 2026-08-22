##[>] 🤖🤖
PROSE_ASSETS_REF={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_PROSE_ASSETS_REF" }}
CONFIGS_REF={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_CONFIGS_REF" }}
MISC_REF={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_MISC_REF" }}
PROSE_SPEC_REF={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_PROSE_SPEC_REF" }}
ARTIFACT_REGISTRY={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_ARTIFACT_REGISTRY" }}
CI_IMAGES_REF={{ shell "glab variable get -g konradodwrot GRP_KO_VAR_CI_IMAGES_REF" }}
GITLAB_TOKEN={{ secret "op://ProgrammaticAccess/gitlab/access_token" }}
GOOGLE_CREDENTIALS={{ shell "glab variable get -R konradodwrot/cross-repo/infra/iac REPO_VAR_GOOGLE_CREDENTIALS" }}
TF_VAR_github_token={{ shell "glab variable get -R konradodwrot/cross-repo/infra/iac REPO_VAR_GITHUB_TOKEN" }}
TF_VAR_ci_gitlab_token={{ shell "glab variable get -R konradodwrot/cross-repo/infra/iac REPO_VAR_GITLAB_TOKEN" }}
TF_VAR_ci_google_credentials={{ shell "glab variable get -R konradodwrot/cross-repo/infra/iac REPO_VAR_GOOGLE_CREDENTIALS" }}
TF_VAR_op_service_account_token={{ shell "glab variable get -R konradodwrot/cross-repo/infra/iac REPO_VAR_OP_SERVICE_ACCOUNT_TOKEN" }}
TF_VAR_gcp_billing_account={{ shell "glab variable get -R konradodwrot/cross-repo/infra/iac REPO_VAR_GCP_BILLING_ACCOUNT" }}
##[<] 🤖🤖
