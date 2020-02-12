locals {
  prefix-hub         = "hub"
  hub-location       = "CentralUS"
  hub-resource-group = "hub-vnet-rg"
  hub-vnet = "hub-vnet"
}

resource "azurerm_resource_group" "hub" {
  name     = local.hub-resource-group
  location = local.hub-location
}

resource "azurerm_virtual_network" "hub" {
  name                = local.hub-vnet
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "hub_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefix       = "10.0.255.224/27"
}

resource "azurerm_subnet" "hub_mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefix       = "10.0.0.64/27"
}

resource "azurerm_subnet" "hub_dmz" {
  name                 = "dmz"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefix       = "10.0.0.32/27"
}

resource "azurerm_network_interface" "hub_vm" {
  name                 = "${local.prefix-hub}-vm-nic"
  location             = azurerm_resource_group.hub.location
  resource_group_name  = azurerm_resource_group.hub.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = local.prefix-hub
    subnet_id                     = azurerm_subnet.hub_mgmt.id
    private_ip_address_allocation = "Dynamic"
  }
}

#Virtual Machine
resource "azurerm_virtual_machine" "hub_vm" {
  name                  = "${local.prefix-hub}-vm"
  location              = azurerm_resource_group.hub.location
  resource_group_name   = azurerm_resource_group.hub.name
  network_interface_ids = [azurerm_network_interface.hub_vm.id]
  vm_size               = var.vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "hubvmosdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.prefix-hub}-vm"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# Virtual Network Gateway
resource "azurerm_public_ip" "hub_gateway" {
  name                = "hub-vpn-gateway-pip"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "hub_gateway" {
  name                = "hub-vpn-gateway"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.hub_gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hub_gateway.id
  }
  depends_on = ["azurerm_public_ip.hub_gateway"]
}

