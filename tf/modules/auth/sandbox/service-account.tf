##[>] 🤖🤖
resource "google_service_account" "sandbox" {
  project      = google_project_service.iam.project
  account_id   = "sandbox"
  display_name = "Sandbox (Secrets Manager read)"
}

resource "google_service_account_key" "sandbox" {
  service_account_id = google_service_account.sandbox.name

  depends_on = [google_org_policy_policy.allow_sa_key_creation]
}

resource "tls_private_key" "sandbox" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "tls_private_key" "sandbox_signing" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}
##[<] 🤖🤖
