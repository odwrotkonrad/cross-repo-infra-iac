##[>] 🤖🤖
variable "gcp_org_id" {
  type = string
}

variable "gcp_project" {
  type = string
}

variable "gcp_applier_member" {
  type = string
}

variable "gcp_ci_member" {
  type = string
}

variable "gcp_billing_account" {
  type      = string
  sensitive = true
}

variable "budget_amount" {
  type    = string
  default = "100"
}


variable "budget_alert_email" {
  type = string
}

##[<] 🤖🤖
