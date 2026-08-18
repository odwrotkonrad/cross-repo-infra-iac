##[>] 🤖🤖
resource "google_monitoring_notification_channel" "budget_email" {
  project      = var.gcp_project
  display_name = "budget alerts (email)"
  type         = "email"

  labels = {
    email_address = var.budget_alert_email
  }
}

resource "google_billing_budget" "total" {
  billing_account = var.gcp_billing_account
  display_name    = "konradodwrot total spend"

  amount {
    specified_amount {
      units = var.budget_amount
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
    monitoring_notification_channels = [google_monitoring_notification_channel.budget_email.id]
    disable_default_iam_recipients   = false
  }

  depends_on = [google_project_service.billingbudgets]
}
##[<] 🤖🤖
