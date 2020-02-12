locals {
  shared-key         = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}

resource "azurerm_virtual_network_gateway_connection" "hub_to_onprem" {
  name                = "hub-onprem-connection"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  type           = "Vnet2Vnet"
  routing_weight = 1
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.hub_gateway.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.onprem_gateway.id
  shared_key = local.shared-key
}

resource "azurerm_virtual_network_gateway_connection" "onprem_to_hub" {
  name                = "onprem-hub-connection"
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name
  type                            = "Vnet2Vnet"
  routing_weight = 1
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.onprem_gateway.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.hub_gateway.id
  shared_key = local.shared-key
}
