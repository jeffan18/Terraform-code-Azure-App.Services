resource "azurerm_subnet" "ingress" {
  name                 = "${var.vnet_name}-ingress-subnet"
  resource_group_name = azurerm_resource_group.fanfan.name
  virtual_network_name = "${azurerm_virtual_network.fanfan.name}"
  address_prefix       = var.subnet_gateway_ingress
}

resource "azurerm_subnet" "gateway" {
  name                 = "${var.vnet_name}-gateway-subnet"
  resource_group_name = azurerm_resource_group.fanfan.name
  virtual_network_name = "${azurerm_virtual_network.fanfan.name}"
  address_prefix       = var.subnet_gateway
}

# Network security groups
resource azurerm_network_security_group "aks" {
  name                = "NSG-aks"
  location            = azurerm_resource_group.fanfan.location
  resource_group_name = azurerm_resource_group.fanfan.name
}

resource azurerm_network_security_group "ingress" {
  name                = "NSG-ingress"
  location            = azurerm_resource_group.fanfan.location
  resource_group_name = azurerm_resource_group.fanfan.name
}

resource azurerm_network_security_group "gateway" {
  name                = "NSG-gateway"
  location            = azurerm_resource_group.fanfan.location
  resource_group_name = azurerm_resource_group.fanfan.name
}

# set NSG association with subnet
resource "azurerm_subnet_network_security_group_association" "aks" {
  subnet_id                 = "${azurerm_subnet.aks.id}"
  network_security_group_id = "${azurerm_network_security_group.aks.id}"
}

resource "azurerm_subnet_network_security_group_association" "ingress" {
  subnet_id                 = "${azurerm_subnet.ingress.id}"
  network_security_group_id = "${azurerm_network_security_group.ingress.id}"
}

resource "azurerm_subnet_network_security_group_association" "gateway" {
  subnet_id                 = "${azurerm_subnet.gateway.id}"
  network_security_group_id = "${azurerm_network_security_group.gateway.id}"
}


# Application Gateway
locals {
  gateway_name                   = "${var.dns_prefix}-${var.project}-${var.environment}-appgw"
  gateway_ip_name                = "${var.dns_prefix}-${var.project}-${var.environment}-appgw-ip"
  gateway_ip_config_name         = "${var.project}-appgw-ipconfig"
  frontend_port_name             = "${var.project}-appgw-feport"
  frontend_ip_configuration_name = "${var.project}-appgw-feip"
  backend_address_pool_name      = "${var.project}-appgw-bepool"
  http_setting_name              = "${var.project}-appgw-http"
  probe_name                     = "${var.project}-appgw-probe"
  listener_name                  = "${var.project}-appgw-lstn"
  ssl_name                       = "${var.project}-appgw-ssl"
  url_path_map_name              = "${var.project}-appgw-urlpath"
  url_path_map_rule_name         = "${var.project}-appgw-urlrule"
  request_routing_rule_name      = "${var.project}-appgw-router"
}

resource "azurerm_public_ip" "gateway" {
  name                = "${local.gateway_ip_name}"
  location            = azurerm_resource_group.fanfan.location
  resource_group_name = azurerm_resource_group.fanfan.name
  domain_name_label   = "${local.gateway_name}"
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "gateway" {
  name                = "${local.gateway_name}"
  location            = azurerm_resource_group.fanfan.location
  resource_group_name = azurerm_resource_group.fanfan.name

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "${local.gateway_ip_config_name}"
    subnet_id = "${azurerm_subnet.gateway.id}"
  }

  frontend_port {
    name = "${local.frontend_port_name}-http"
    port = 80
  }

  frontend_port {
    name = "${local.frontend_port_name}-https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "${local.frontend_ip_configuration_name}"
    public_ip_address_id = "${azurerm_public_ip.gateway.id}"
  }

  backend_address_pool {
    name         = "${local.backend_address_pool_name}"
    ip_addresses = ["${var.vip_load_balancer_ingress}"]
  }

  backend_http_settings {
    name                  = "${local.http_setting_name}"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "http"
    request_timeout       = 1
    probe_name            = "${local.probe_name}"
  }

  http_listener {
    name                           = "${local.listener_name}-http"
    frontend_ip_configuration_name = "${local.frontend_ip_configuration_name}"
    frontend_port_name             = "${local.frontend_port_name}-http"
    protocol                       = "http"
  }

  probe {
    name                = "${local.probe_name}"
    protocol            = "http"
    path                = "/nginx-health"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    host                = "${var.vip_load_balancer_ingress}"
  }

  request_routing_rule {
    name                           = "${local.request_routing_rule_name}-http"
    rule_type                      = "PathBasedRouting"
    http_listener_name             = "${local.listener_name}-http"
    url_path_map_name              = "${local.url_path_map_name}"
  }

  url_path_map {
    name                               = "${local.url_path_map_name}"
    default_backend_address_pool_name  = "${local.backend_address_pool_name}"
    default_backend_http_settings_name = "${local.http_setting_name}"
    
    path_rule {
      name                       = "${local.url_path_map_rule_name}"
      backend_address_pool_name  = "${local.backend_address_pool_name}"
      backend_http_settings_name = "${local.http_setting_name}"
      paths = [
        "/*"
      ]
    }
  }
}
