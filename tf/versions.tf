##[>] 🤖🤖
terraform {
  required_version = "~> 1.15"

  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 18.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 2.1"
    }
  }

  backend "gcs" {
    bucket = "konradodwrot-restricted-tfstate"
    prefix = "restricted-infra"
  }
}
##[<] 🤖🤖
