# Assign Locals parameters - for future hard coded use for App GW definition
# Terraform Resource "azurerm_virtual_network.appgwtest" will be defined later
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.appgwtest.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.appgwtest.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.appgwtest.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.appgwtest.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.appgwtest.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.appgwtest.name}-rqrt"
}

# Resource group is already created, just use the name - noticed that we use "data", not "resource" here
data "azurerm_resource_group" "existing_rg" {
  name = var.resource_group_name
}

# Define VNET and subnets
resource "azurerm_virtual_network" "appgwtest" {
  name                = var.virtual_network_name
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  address_space       = [var.virtual_network_address_prefix]

  subnet {
    name           = var.aks_subnet_name
    address_prefix = var.aks_subnet_address_prefix
  }

  subnet {
    name           = var.app_gateway_subnet_name
    address_prefix = var.app_gateway_subnet_address_prefix
  }

  tags = var.tags
}

data "azurerm_subnet" "kubesubnet" {
  name                 = var.aks_subnet_name
  virtual_network_name = azurerm_virtual_network.appgwtest.name
  resource_group_name  = data.azurerm_resource_group.existing_rg.name
}

data "azurerm_subnet" "appgwsubnet" {
  name                 = var.app_gateway_subnet_name
  virtual_network_name = azurerm_virtual_network.appgwtest.name
  resource_group_name  = data.azurerm_resource_group.existing_rg.name
}

# Define Public IP for App Gateway: "AppGW1-in-Subnet02-in-VNet02"
resource "azurerm_public_ip" "appgwtest" {
  name                         = "PublicIP1-for-AppGW1"
  location                     = data.azurerm_resource_group.existing_rg.location
  resource_group_name          = data.azurerm_resource_group.existing_rg.name
  allocation_method            = "Static"
  sku                          = "Standard"

  tags = var.tags
}

#Define the Application Gateway
resource "azurerm_application_gateway" "appgwtest" {
  name                = var.app_gateway_name
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  location            = data.azurerm_resource_group.existing_rg.location

  sku {
    name     = var.app_gateway_sku
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "AppGW1-IPConfig-in-Subnet02-in-Vnet02"
    subnet_id = data.azurerm_subnet.appgwsubnet.id
  }

# Use "local" which the parameters was defined before
  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_port {
    name = "HTTPSPort"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgwtest.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  tags = var.tags

  depends_on = ["azurerm_virtual_network.appgwtest", "azurerm_public_ip.appgwtest"]
}
