# 1. Resource Group Fetching (Single Source of Truth)
data "azurerm_resource_group" "existing_rg" {
  name = var.resource_group_name
}

# 2. Azure Automation Account Configuration
resource "azurerm_automation_account" "finops_automation" {
  name                = "aa-appx-finops-01"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  sku_name            = "Basic"

  # System-Assigned Managed Identity enabled for passwordless login
  identity {
    type = "SystemAssigned"
  }

  tags = var.mandatory_tags
}

resource "azurerm_role_assignment" "automation_rbac" {
  scope                = data.azurerm_resource_group.existing_rg.id
  role_definition_name = "Contributor"
  principal_id         = one(azurerm_automation_account.finops_automation.identity).principal_id
}

# 4. Import VM Snoozer PowerShell Script into Azure Runbook
resource "azurerm_automation_runbook" "vm_snoozer" {
  name                    = "runbook-vm-snoozer"
  location                = data.azurerm_resource_group.existing_rg.location
  resource_group_name     = data.azurerm_resource_group.existing_rg.name
  automation_account_name = azurerm_automation_account.finops_automation.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "Auto stop dev VMs at night"
  runbook_type            = "PowerShell"

content = file("${path.module}/scripts/vm-snoozer.ps1")

  # ===> YEH LINE ENGINE ME ADD KARNI HAI <===
  tags = var.mandatory_tags
}

# 5. Import Zombie Resource Hunter Script into Azure Runbook
resource "azurerm_automation_runbook" "zombie_hunter" {
  name                    = "runbook-zombie-hunter"
  location                = data.azurerm_resource_group.existing_rg.location
  resource_group_name     = data.azurerm_resource_group.existing_rg.name
  automation_account_name = azurerm_automation_account.finops_automation.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "Clean unattached disks and IPs"
  runbook_type            = "PowerShell"
content = file("${path.module}/scripts/zombie-hunter.ps1")

  # ===> YEH LINE BHI YAHAN ADD KARNI HAI <===
  tags = var.mandatory_tags
}

# 6. Schedule: Nightly 8 PM UTC Automation Job Trigger
resource "azurerm_automation_schedule" "daily_night" {
  name                    = "sched-daily-8pm"
  resource_group_name     = data.azurerm_resource_group.existing_rg.name
  automation_account_name = azurerm_automation_account.finops_automation.name
  frequency               = "Day"
  interval                = 1
  
  # Time badal kar 4:18 PM IST kar diya taaki 5 minute se zyada ka gap ho jaye
  start_time              = "2026-05-21T16:18:00+05:30" 
  
  description             = "Triggers every night to stop non-prod resources"
}

# 7. Job Schedule: Linking the Schedule to the VM Snoozer Runbook
resource "azurerm_automation_job_schedule" "link_snoozer" {
  resource_group_name     = data.azurerm_resource_group.existing_rg.name
  automation_account_name = azurerm_automation_account.finops_automation.name
  runbook_name            = azurerm_automation_runbook.vm_snoozer.name
  schedule_name           = azurerm_automation_schedule.daily_night.name
}