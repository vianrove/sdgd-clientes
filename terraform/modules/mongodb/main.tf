### Mongo database
resource "azurerm_cosmosdb_account" "mongodb" {
  enable_free_tier    = true
  kind                = "MongoDB"
  location            = "westus3"
  name                = "dochub-mongodb"
  offer_type          = "Standard"
  resource_group_name = var.resourcegroupname
  tags = {
    defaultExperience       = "Azure Cosmos DB for MongoDB API"
    hidden-cosmos-mmspecial = ""
  }
  consistency_policy {
    consistency_level = "Session"
  }
  geo_location {
    failover_priority = 0
    location          = "westus3"
  }
}
variable "resourcegroupname" {
  type        = string
  description = "resource group name"
}