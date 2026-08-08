##[>] 🤖🤖
data "onepassword_vault" "this" {
  name = var.op_vault
}

#[why] alphanumeric-only and 32 chars: satisfies GitLab masking (>=8 chars, no spaces, base64-safe charset) by construction
resource "random_password" "passphrase" {
  length  = 32
  special = false
}

#[why] prevent_destroy: replacing the key re-signs the apt repo under a new identity and breaks every installed client until they re-fetch gpg.key; rotation must be an explicit, deliberate state operation
resource "gpg_private_key" "apt_signing" {
  name       = var.gpg_name
  email      = var.gpg_email
  passphrase = random_password.passphrase.result
  rsa_bits   = 4096

  lifecycle {
    prevent_destroy = true
  }
}

#[why] durable record in the vault for humans and non-CI consumers; the CI variables below read the terraform resources directly
resource "onepassword_item" "apt_signing" {
  vault    = data.onepassword_vault.this.uuid
  title    = "apt-signing-gpg"
  category = "secure_note"

  section {
    label = "keys"

    field {
      label = "private_key"
      type  = "CONCEALED"
      value = gpg_private_key.apt_signing.private_key
    }

    field {
      label = "passphrase"
      type  = "CONCEALED"
      value = random_password.passphrase.result
    }

    field {
      label = "public_key"
      type  = "STRING"
      value = gpg_private_key.apt_signing.public_key
    }
  }
}

#[why] protected: exposed only to protected-ref pipelines (main + release tags below), so a Developer-token branch push cannot read the signing key. file type: multiline armored key, read as a path by publish-apt.zsh. raw: armored body must not be $-expanded
resource "gitlab_project_variable" "apt_gpg_private_key" {
  project       = var.go_modules_project_path
  key           = "APT_GPG_PRIVATE_KEY"
  value         = gpg_private_key.apt_signing.private_key
  variable_type = "file"
  protected     = true
  raw           = true
}

resource "gitlab_project_variable" "apt_gpg_passphrase" {
  project   = var.go_modules_project_path
  key       = "APT_GPG_PASSPHRASE"
  value     = random_password.passphrase.result
  masked    = true
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
