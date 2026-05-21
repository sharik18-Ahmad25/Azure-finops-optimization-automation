# 1. Company ka standard Storage Account (simulating legacy data store)
resource "azurerm_storage_account" "appx_storage" {
  name                     = "saappxfinopslogs01" # Storage name must be globally unique
  resource_group_name      = data.azurerm_resource_group.existing_rg.name
  location                 = data.azurerm_resource_group.existing_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # Enforcing tags manually during migration to governance
  tags = var.mandatory_tags
}

# 2. Automated Storage Lifecycle Management Policy (The Saver)
resource "azurerm_storage_management_policy" "lifecycle_policy" {
  storage_account_id = azurerm_storage_account.appx_storage.id

  rule {
    name    = "log-tiering-and-cleanup-rule"
    enabled = true
    filters {
      prefix_match = ["container-logs/"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        # Agar blob create hue 30 din ho gaye hain, toh Cool Tier me bhej do (Sasta tier)
        tier_to_cool_after_days_since_creation_greater_than = 30
        
        # Agar blob 90 din se purana hai, toh Archive Tier me daal do (Sabse sasta tier)
        tier_to_archive_after_days_since_creation_greater_than = 90
        
        # Agar blob 365 din se purana hai, toh permanently delete kar do (Zero cost)
        delete_after_days_since_creation_greater_than = 365
      }
    }
  }
}