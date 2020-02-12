locals {
  spoke2-location       = "CentralUS"
  spoke2-resource-group = "spoke2-vnet-rg"
  prefix-spoke2         = "spoke2"
}

resource "azurerm_resource_group" "spoke2" {
  name     = local.spoke2-resource-group
  location = local.spoke2-location
}

resource "azurerm_virtual_network" "spoke2" {
  name                = "spoke2-vnet"
  location            = azurerm_resource_group.spoke2.location
  resource_group_name = azurerm_resource_group.spoke2.name
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "spoke2_mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.spoke2.name
  virtual_network_name = azurerm_virtual_network.spoke2.name
  address_prefix       = "10.2.0.64/27"
}

resource "azurerm_subnet" "spoke2_workload" {
  name                 = "workload"
  resource_group_name  = azurerm_resource_group.spoke2.name
  virtual_network_name = azurerm_virtual_network.spoke2.name
  address_prefix       = "10.2.1.0/24"
}

resource "azurerm_network_interface" "spoke2_vm" {
  name                 = "${local.prefix-spoke2}-vm-nic"
  location             = azurerm_resource_group.spoke2.location
  resource_group_name  = azurerm_resource_group.spoke2.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "spoke2_ip_configuration"
    subnet_id                     = azurerm_subnet.spoke2_mgmt.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "spoke2_vm" {
  name                  = "${local.prefix-spoke2}-vm"
  location              = azurerm_resource_group.spoke2.location
  resource_group_name   = azurerm_resource_group.spoke2.name
  network_interface_ids = [azurerm_network_interface.spoke2_vm.id]
  vm_size               = var.vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "spoke2vmosdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.prefix-spoke2}-vm"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
