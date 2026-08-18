##[>] 🤖🤖
data "onepassword_vault" "this" {
  name = var.op_vault
}

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
