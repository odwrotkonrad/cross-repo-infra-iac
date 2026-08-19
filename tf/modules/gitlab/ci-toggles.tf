##[>] 🤖🤖
resource "gitlab_group_variable" "enable_darwin_ci" {
  group     = var.token_group_path
  key       = "ENABLE_DARWIN_CI"
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
  key       = "CHE_PACKAGES_REF"
  value     = var.che_packages_ref
  masked    = false
  protected = false
}
##[<] 🤖🤖
