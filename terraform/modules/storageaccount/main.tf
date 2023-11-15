### Storage account
resource "azurerm_storage_account" "storage-account" {
  account_replication_type         = "RAGRS"
  account_tier                     = "Standard"
  cross_tenant_replication_enabled = false
  location                         = "eastus"
  name                             = "dochubstoragedocuments"
  resource_group_name              = var.resourcegroupname
}

variable "resourcegroupname" {
  type        = string
  description = "resource group name"
}