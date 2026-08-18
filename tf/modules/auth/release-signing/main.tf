##[>] 🤖🤖
data "onepassword_vault" "this" {
  name = var.op_vault
}

resource "random_password" "passphrase" {
  length  = 32
  special = false
}

resource "gpg_private_key" "apt_signing" {
  name       = var.gpg_name
  email      = var.gpg_email
  passphrase = random_password.passphrase.result
  rsa_bits   = 4096

  lifecycle {
    prevent_destroy = true
  }
}

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

resource "gitlab_tag_protection" "release_tags" {
  project             = var.go_modules_project_path
  tag                 = "*"
  create_access_level = "maintainer"
}
##[<] 🤖🤖
