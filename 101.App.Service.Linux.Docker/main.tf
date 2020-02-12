provider "azurerm" {
 subscription_id = ""
 tenant_id = ""
 client_id = ""
 client_secret = ""
}

terraform {
 backend "azurerm" {
  resource_group_name   = "RG-Common-Resources"
  storage_account_name  = "forterraformbackend"
  container_name        = "tfstate"
  key = "+0ZsjudDQwFyiXMCYr65X+hWBYP5c1nhVtTvGhjsU4j25LI2F5nlgCawK8GRHN2go1JBP2gSvzySk+/GNAJ3XQ=="
 }
}
