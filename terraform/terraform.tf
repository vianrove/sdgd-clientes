terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.65.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "dochub-terraform"
    storage_account_name = "terraformstoragedochub"
    container_name       = "tfstatedevops"
    key                  = "terraform.tfstate"
  }
}
