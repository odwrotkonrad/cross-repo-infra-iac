##[>] 🤖🤖
import {
  to = module.gitlab.gitlab_project_variable.ci_gitlab_token
  id = "konradodwrot/infra/iac:TF_GITLAB_TOKEN:*"
}

import {
  to = module.gitlab.gitlab_project_variable.ci_github_token
  id = "konradodwrot/infra/iac:GITHUB_TOKEN:*"
}

import {
  to = module.gitlab.gitlab_project_variable.google_credentials
  id = "konradodwrot/infra/iac:GOOGLE_CREDENTIALS:*"
}

#[why] the staging project predates this config: adopt it into state rather than creating a new one.
#   billing lands on it as part of the same apply, which is what makes GKE creatable there
import {
  to = module.ci_cluster.google_project.ci
  id = "projects/staging-499418"
}
##[<] 🤖🤖
