##[>] 🤖🤖
provider "gitlab" {}

provider "github" {
  owner = var.github_owner
  token = var.github_token
}

provider "google" {
  project = var.gcp_project
}

provider "onepassword" {
  service_account_token = var.op_service_account_token
}
##[<] 🤖🤖
