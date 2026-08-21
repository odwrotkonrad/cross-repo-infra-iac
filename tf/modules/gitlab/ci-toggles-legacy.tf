##[>] 🤖🤖
resource "gitlab_group_variable" "enable_darwin_ci_legacy" {
  group     = var.token_group_path
  key       = "GRP_VAR_ENABLE_DARWIN_CI"
  value     = var.ENABLE_DARWIN_CI
  masked    = false
  protected = false
}

resource "gitlab_group_variable" "che_packages_ref_legacy" {
  group     = var.token_group_path
  key       = "GRP_VAR_CHE_PACKAGES_REF"
  value     = var.CHE_PACKAGES_REF
  masked    = false
  protected = false
}

resource "gitlab_group_variable" "che_backup_auto_create_legacy" {
  group     = var.token_group_path
  key       = "GRP_VAR_CHE_BACKUP_AUTO_CREATE"
  value     = var.CHE_BACKUP_AUTO_CREATE
  masked    = false
  protected = false
}

resource "gitlab_group_variable" "ci_images_ref_legacy" {
  group     = var.token_group_path
  key       = "GRP_VAR_CI_IMAGES_REF"
  value     = var.CI_IMAGES_REF
  masked    = false
  protected = false
}

resource "gitlab_group_variable" "ci_registry_legacy" {
  group     = var.token_group_path
  key       = "GRP_VAR_ARTIFACT_REGISTRY"
  value     = var.ci_registry
  masked    = false
  protected = false
}

resource "gitlab_group_variable" "gitlab_registry_proxy_legacy" {
  group     = var.token_group_path
  key       = "GRP_VAR_ARTIFACT_REGISTRY_PROXY_GITLAB"
  value     = var.gitlab_registry_proxy
  masked    = false
  protected = false
}

resource "gitlab_group_variable" "dockerhub_registry_proxy_legacy" {
  group     = var.token_group_path
  key       = "GRP_VAR_ARTIFACT_REGISTRY_PROXY_DOCKERHUB"
  value     = var.dockerhub_registry_proxy
  masked    = false
  protected = false
}

resource "gitlab_group_variable" "gitlab_token_legacy" {
  group     = var.token_group_path
  key       = "GRP_VAR_GITLAB_TOKEN"
  value     = gitlab_group_access_token.remote_sources.token
  masked    = true
  protected = false
}
##[<] 🤖🤖
