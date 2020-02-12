locals {
  spoke1-location       = "CentralUS"
  spoke1-resource-group = "spoke1-vnet-rg"
  prefix-spoke1         = "spoke1"
}

resource "azurerm_resource_group" "spoke1" {
  name     = local.spoke1-resource-group
  location = local.spoke1-location
}

resource "azurerm_virtual_network" "spoke1" {
  name                = "spoke1-vnet"
  location            = azurerm_resource_group.spoke1.location
  resource_group_name = azurerm_resource_group.spoke1.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "spoke1_mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.spoke1.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefix       = "10.1.0.64/27"
}

resource "azurerm_subnet" "spoke1_workload" {
  name                 = "workload"
  resource_group_name  = azurerm_resource_group.spoke1.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefix       = "10.1.1.0/24"
}

resource "azurerm_network_interface" "spoke1_vm" {
  name                 = "${local.prefix-spoke1}-vm-nic"
  location             = azurerm_resource_group.spoke1.location
  resource_group_name  = azurerm_resource_group.spoke1.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "spoke1_ip_configuration"
    subnet_id                     = azurerm_subnet.spoke1_mgmt.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "spoke1_vm" {
  name                  = "${local.prefix-spoke1}-vm"
  location              = azurerm_resource_group.spoke1.location
  resource_group_name   = azurerm_resource_group.spoke1.name
  network_interface_ids = [azurerm_network_interface.spoke1_vm.id]
  vm_size               = var.vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "spoke1vmosdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.prefix-spoke1}-vm"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
