locals {
  onprem-location       = "SouthCentralUS"
  onprem-resource-group = "onprem-vnet-rg"
  prefix-onprem         = "onprem"
}

resource "azurerm_resource_group" "onprem" {
  name     = local.onprem-resource-group
  location = local.onprem-location
}

resource "azurerm_virtual_network" "onprem" {
  name                = "onprem-vnet"
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "onprem_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.onprem.name
  virtual_network_name = azurerm_virtual_network.onprem.name
  address_prefix       = "192.168.255.224/27"
}

resource "azurerm_subnet" "onprem_mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.onprem.name
  virtual_network_name = azurerm_virtual_network.onprem.name
  address_prefix       = "192.168.1.128/25"
}

resource "azurerm_public_ip" "onprem_vm" {
  name                         = "${local.prefix-onprem}-vm-pip"
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "onprem_vm" {
  name                 = "${local.prefix-onprem}-vm-nic"
  location             = azurerm_resource_group.onprem.location
  resource_group_name  = azurerm_resource_group.onprem.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "onprem-vm-ip-config"
    subnet_id                     = azurerm_subnet.onprem_mgmt.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.onprem_vm.id
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "onprem_vm" {
    name                = "${local.prefix-onprem}vm-nsg"
    location            = azurerm_resource_group.onprem.location
    resource_group_name = azurerm_resource_group.onprem.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_subnet_network_security_group_association" "mgmt_nsg_association" {
  subnet_id                 = azurerm_subnet.onprem_mgmt.id
  network_security_group_id = azurerm_network_security_group.onprem_vm.id
}

resource "azurerm_virtual_machine" "onprem_vm" {
  name                  = "${local.prefix-onprem}-vm"
  location              = azurerm_resource_group.onprem.location
  resource_group_name   = azurerm_resource_group.onprem.name
  network_interface_ids = [azurerm_network_interface.onprem_vm.id]
  vm_size               = var.vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "onpremvmosdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.prefix-onprem}-linux-vm"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_public_ip" "onprem_gateway" {
  name                = "${local.prefix-onprem}-vpn-gateway-pip"
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "onprem_gateway" {
  name                = "onprem-vpn-gateway"
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "OnpremVPNGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.onprem_gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.onprem_gateway.id
  }
  depends_on = ["azurerm_public_ip.onprem_gateway"]
}

