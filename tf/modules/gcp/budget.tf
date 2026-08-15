##[>] 🤖🤖
#[why] channels live in the quota project: budgets are billing-account scoped but notification
#   channels are a Monitoring resource and need a project to live in
resource "google_monitoring_notification_channel" "budget_email" {
  project      = var.gcp_project
  display_name = "budget alerts (email)"
  type         = "email"

  labels = {
    email_address = var.budget_alert_email
  }
}

#[why] optional: terraform creates the channel but the number needs a one-time console verification
#   before it delivers, so an unset variable must not block the apply
resource "google_monitoring_notification_channel" "budget_sms" {
  count = var.budget_alert_sms != "" ? 1 : 0

  project      = var.gcp_project
  display_name = "budget alerts (sms)"
  type         = "sms"

  labels = {
    number = var.budget_alert_sms
  }
}

#[why] whole billing account, not one project: the figure must read as total GCP exposure.
#   thresholds are fractions of the amount, so raising budget_amount moves warn and critical together.
#   forecasted fires while there is still time to act; the two actual rules fire after the fact
#   (billing data lags hours). nothing here caps spend: budgets notify only
resource "google_billing_budget" "total" {
  billing_account = var.gcp_billing_account
  display_name    = "konradodwrot total spend"

  amount {
    specified_amount {
      currency_code = var.budget_currency
      units         = var.budget_amount
    }
  }

  threshold_rules {
    threshold_percent = 0.5
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "FORECASTED_SPEND"
  }

  all_updates_rule {
    monitoring_notification_channels = concat(
      [google_monitoring_notification_channel.budget_email.id],
      google_monitoring_notification_channel.budget_sms[*].id,
    )
    #[why] billing admins keep receiving the default mail as a backstop if a channel breaks
    disable_default_iam_recipients = false
  }

  depends_on = [google_project_service.billingbudgets]
}
##[<] 🤖🤖
