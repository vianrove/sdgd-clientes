### Service plan EAST-US
resource "azurerm_service_plan" "service-plan1" {
  location            = "eastus"
  name                = "AppServicePlan-Region1"
  os_type             = "Linux"
  resource_group_name = var.resourcegroupname
  sku_name            = "B1"
  tags = {
    Region1 = "AppServicePlan"
  }
}

### Service plan WEST-US
resource "azurerm_service_plan" "service-plan2" {
  location            = "westus3"
  name                = "AppServicePlan-Region2"
  os_type             = "Linux"
  resource_group_name = var.resourcegroupname
  sku_name            = "B1"
  tags = {
    Region2 = "AppServicePlan"
  }
}

variable "resourcegroupname" {
  type        = string
  description = "resource group name"
}