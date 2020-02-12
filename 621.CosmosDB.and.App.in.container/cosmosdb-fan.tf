resource "azurerm_resource_group" "fan-tf-group" {
  name = "RG03-eastus-20200122"
  location = "eastus"
}

resource "azurerm_cosmosdb_account" "fan-cosmos-db" {
  name = "cosmosdb01eastus20200122"
  location = azurerm_resource_group.fan-tf-group.location
  resource_group_name = azurerm_resource_group.fan-tf-group.name
  offer_type = "Standard"
  kind = "GlobalDocumentDB"
  consistency_policy {
    consistency_level = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix = 200
  }
  geo_location {
    location = "eastus"
    failover_priority = 0
  }
}
