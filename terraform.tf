terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.65.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "sdgd_terraform"
    storage_account_name = "terraformstoragesdgd1"
    container_name       = "tfstatesdevops"
    key                  = "terraform.tfstate"
  }
}
