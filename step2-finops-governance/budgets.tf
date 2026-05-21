resource "azurerm_consumption_budget_resource_group" "appx_budget" {
  name              = "bg-appx-dev-monthly"
  resource_group_id = data.azurerm_resource_group.existing_rg.id

  amount     = 20
  time_grain = "Monthly"

  time_period {
    start_date = "2026-05-01T00:00:00Z" # Current project lifecycle timeline tracking
    end_date   = "2028-05-01T00:00:00Z"
  }

  # Alert 1: 80% Budget Consume hone par Warning Email
  notification {
    enabled   = true
    threshold = 80
    operator  = "GreaterThan"
    contact_emails = [
      "sharikahmad1825@gmail.com" # Directly linked from your profile profile metadata [cite: 3]
    ]
  }

  # Alert 2: 100% Budget Consume hone par Critical Notification
  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    contact_emails = ["sharikahmad1825@gmail.com"] # [cite: 3]
  }
}