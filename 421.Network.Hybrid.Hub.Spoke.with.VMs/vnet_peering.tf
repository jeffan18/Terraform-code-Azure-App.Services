resource "azurerm_virtual_network_peering" "hub-spoke1-peer" {
  name                      = "hub-spoke1-peer"
  resource_group_name       = azurerm_resource_group.hub.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
  use_remote_gateways       = false
  depends_on = ["azurerm_virtual_network.spoke1", "azurerm_virtual_network.hub", "azurerm_virtual_network_gateway.hub_gateway"]
}

resource "azurerm_virtual_network_peering" "spoke1-hub-peer" {
  name                      = "spoke1-hub-peer"
  resource_group_name       = azurerm_resource_group.spoke1.name
  virtual_network_name      = azurerm_virtual_network.spoke1.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit   = false
  use_remote_gateways     = true
  depends_on = ["azurerm_virtual_network.spoke1", "azurerm_virtual_network.hub" , "azurerm_virtual_network_gateway.hub_gateway"]
}

resource "azurerm_virtual_network_peering" "hub-spoke2-peer" {
  name                      = "hub-spoke2-peer"
  resource_group_name       = azurerm_resource_group.hub.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
  use_remote_gateways       = false
  depends_on = ["azurerm_virtual_network.spoke2", "azurerm_virtual_network.hub", "azurerm_virtual_network_gateway.hub_gateway"]
}

resource "azurerm_virtual_network_peering" "spoke2-hub-peer" {
  name                      = "spoke2-hub-peer"
  resource_group_name       = azurerm_resource_group.spoke2.name
  virtual_network_name      = azurerm_virtual_network.spoke2.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  allow_gateway_transit   = false
  use_remote_gateways     = true
  depends_on = ["azurerm_virtual_network.spoke2", "azurerm_virtual_network.hub" , "azurerm_virtual_network_gateway.hub_gateway"]
}
