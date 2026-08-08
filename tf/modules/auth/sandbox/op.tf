##[>] 🤖🤖
data "onepassword_vault" "this" {
  name = var.op_vault
}

#[why] terraform lands the fresh SA key in the vault on apply, replacing the manual `op item edit` step; read by the host as op://<vault>/sandbox-gcp-sa/sa_key
resource "onepassword_item" "sandbox_sa_key" {
  vault    = data.onepassword_vault.this.uuid
  title    = "sandbox-gcp-sa"
  category = "secure_note"

  section {
    label = "keys"

    field {
      label = "sa_key"
      type  = "CONCEALED"
      value = base64decode(google_service_account_key.sandbox.private_key)
    }
  }
}
##[<] 🤖🤖
