##[>] 🤖🤖
data "onepassword_vault" "this" {
  name = var.op_vault
}

#[why] key generated out-of-band once (gpg --quick-gen-key), stored in op item "apt-signing-gpg" fields private_key (armored) + passphrase; terraform only pipes it into CI, never generates it
data "onepassword_item" "apt_signing" {
  vault = data.onepassword_vault.this.uuid
  title = "apt-signing-gpg"
}

locals {
  apt_signing = {
    for f in flatten([for s in data.onepassword_item.apt_signing.section : s.field]) :
    f.label => f.value
  }
}

#[why] protected: exposed only to protected-ref pipelines (main + release tags below), so a Developer-token branch push cannot read the signing key. file type: multiline armored key, read as a path by publish-apt.zsh. raw: armored body must not be $-expanded
resource "gitlab_project_variable" "apt_gpg_private_key" {
  project       = var.go_modules_project_path
  key           = "APT_GPG_PRIVATE_KEY"
  value         = local.apt_signing["private_key"]
  variable_type = "file"
  protected     = true
  raw           = true
}

resource "gitlab_project_variable" "apt_gpg_passphrase" {
  project   = var.go_modules_project_path
  key       = "APT_GPG_PASSPHRASE"
  value     = local.apt_signing["passphrase"]
  masked    = local.apt_signing["passphrase"] != ""
  protected = true
  raw       = true
}

#[why] release tags must be protected refs or tag pipelines never see the protected vars; maintainer create keeps the sandbox Developer token from minting release tags
resource "gitlab_tag_protection" "release_tags" {
  project             = var.go_modules_project_path
  tag                 = "*"
  create_access_level = "maintainer"
}
##[<] 🤖🤖
