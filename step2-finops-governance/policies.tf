# Azure Policy Definition: Requiring 'Environment' Tag for Cost Allocations
resource "azurerm_policy_definition" "tag_policy" {
  name         = "require-env-tag-policy"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Enforce Environment Tag for Cost Tracking"

  policy_rule = <<POLICY
  {
    "if": {
      "field": "tags['Environment']",
      "exists": "false"
    },
    "then": {
      "effect": "Deny"
    }
  }
POLICY
}

# Policy Assignment to the Resource Group Scope
resource "azurerm_resource_group_policy_assignment" "assign_tag_policy" {
  name                 = "assign-env-tag"
  resource_group_id    = data.azurerm_resource_group.existing_rg.id # Referencing data block from main.tf
  policy_definition_id = azurerm_policy_definition.tag_policy.id
  description          = "Denies resource creation if Environment tag is missing"
  display_name         = "Deny Untagged Resources Assignment"
}