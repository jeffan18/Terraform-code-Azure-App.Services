provider "azurerm" {
  version = "=1.36.1"
 subscription_id = ""
 tenant_id = ""
 client_id = ""
 client_secret = ""
}

provider "azuread" {
  version = "=0.6.0"
}

data "azurerm_subscription" "current" {}

