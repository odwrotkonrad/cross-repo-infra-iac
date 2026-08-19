##[>] 🤖🤖
resource "gitlab_group_variable" "enable_darwin_ci" {
  group     = var.token_group_path
  key       = "GRP_VAR_ENABLE_DARWIN_CI"
  value     = var.enable_darwin_ci
  masked    = false
  protected = false
}

#[what] the che-packages catalog version every repo's CI pins to, raised by a catalog release
#[why] a group variable, not a file in go-modules: a pin file inside che/ matched release-che's
#   `changes: [che/**/*]` rule, so raising it cut a che release carrying no che change. this
#   matches no path, and the key is the one che's own packages.source.ref already reads
resource "gitlab_group_variable" "che_packages_ref" {
  group     = var.token_group_path
  key       = "GRP_VAR_CHE_PACKAGES_REF"
  value     = var.che_packages_ref
  masked    = false
  protected = false
}

#[what] whether che archives a dest before mutating it, for the CI jobs that opt in by remapping this
#[why] a throwaway container's archive dies with the layer that holds it, so the bz2 pass over every
#   touched file buys nothing. group-scoped so one place sets it, but no repo puts it in a top-level
#   `variables:` block: che's own test and e2e suites assert that backups happen, and a repo-wide
#   value would reach them and prove the feature against itself
resource "gitlab_group_variable" "che_backup_auto_create" {
  group     = var.token_group_path
  key       = "GRP_VAR_CHE_BACKUP_AUTO_CREATE"
  value     = var.che_backup_auto_create
  masked    = false
  protected = false
}

resource "gitlab_group_variable" "ci_images_ref" {
  group     = var.token_group_path
  key       = "GRP_VAR_CI_IMAGES_REF"
  value     = var.ci_images_ref
  masked    = false
  protected = false
}

resource "gitlab_group_variable" "ci_registry" {
  group     = var.token_group_path
  key       = "GRP_VAR_ARTIFACT_REGISTRY"
  value     = var.ci_registry
  masked    = false
  protected = false
}

resource "gitlab_group_variable" "gitlab_registry_proxy" {
  group     = var.token_group_path
  key       = "GRP_VAR_ARTIFACT_REGISTRY_PROXY_GITLAB"
  value     = var.gitlab_registry_proxy
  masked    = false
  protected = false
}

resource "gitlab_group_variable" "dockerhub_registry_proxy" {
  group     = var.token_group_path
  key       = "GRP_VAR_ARTIFACT_REGISTRY_PROXY_DOCKERHUB"
  value     = var.dockerhub_registry_proxy
  masked    = false
  protected = false
}
##[<] 🤖🤖
