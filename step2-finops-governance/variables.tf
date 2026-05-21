variable "resource_group_name" {
  type    = string
  default = "rg-appx-existing-prod"
}

variable "location" {
  type    = string
  default = "East US"
}

# Governance ke liye mandatory tags define kar rahe hain
variable "mandatory_tags" {
  type = map(string)
  default = {
    Environment = "Dev"
    CostCenter  = "101-AppX"
    Owner       = "Sharik-DevOps"
  }
}