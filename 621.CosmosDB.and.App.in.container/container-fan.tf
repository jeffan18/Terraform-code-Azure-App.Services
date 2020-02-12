resource "azurerm_container_group" "fan-tf-container" {
  name = "ContainerGroup01-eastus-20200122"
  location = azurerm_resource_group.fan-tf-group.location
  resource_group_name = azurerm_resource_group.fan-tf-group.name
  ip_address_type = "public"
  dns_name_label = "fan-app-test"
  os_type = "linux"

  container {
    name = "fan-tf-container"
    image = "microsoft/azure-vote-front:cosmosdb"
    cpu = "0.5"
    memory = "1.5"
    ports {
      port = 80
      protocol = "TCP"
    }

    secure_environment_variables = {
      "COSMOS_DB_ENDPOINT" = azurerm_cosmosdb_account.fan-cosmos-db.endpoint
      "COSMOS_DB_MASTERKEY" = azurerm_cosmosdb_account.fan-cosmos-db.primary_master_key
      "TITLE" = "App Test - Azure Voting App"
      "VOTE1VALUE" = "Cats"
      "VOTE2VALUE" = "Dogs"
    }
  }
}
