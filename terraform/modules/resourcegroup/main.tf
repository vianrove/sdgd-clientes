resource "azurerm_resource_group" "dochub-rg" {
  location = "eastus"
  name     = "DocHub-group"
}

output "resourcegroupname" {
  value = azurerm_resource_group.dochub-rg.name
}