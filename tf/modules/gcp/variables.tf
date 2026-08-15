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

#[why] budget amount as a whole-currency string; thresholds are fractions of it, so raising this moves warn and critical together
variable "budget_amount" {
  type    = string
  default = "100"
}

variable "budget_currency" {
  type    = string
  default = "USD"
}

variable "budget_alert_email" {
  type = string
}

#[why] empty skips the sms channel: the number needs a one-time console verification terraform cannot do
variable "budget_alert_sms" {
  type    = string
  default = ""
}
##[<] 🤖🤖
