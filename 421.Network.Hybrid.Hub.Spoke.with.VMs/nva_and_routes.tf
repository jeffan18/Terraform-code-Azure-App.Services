locals {
  hub-nva-location       = "CentralUS"
  hub-nva-resource-group = "hub-nva-rg"
}

resource "azurerm_resource_group" "hub_nva" {
  name     = local.hub-nva-resource-group
  location = local.hub-nva-location
}

resource "azurerm_network_interface" "hub_nva" {
  name                 = "hub-nva-nic"
  location             = azurerm_resource_group.hub_nva.location
  resource_group_name  = azurerm_resource_group.hub_nva.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "hub-nva-ip-configuration"
    subnet_id                     = azurerm_subnet.hub_dmz.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.36"
  }
}

resource "azurerm_virtual_machine" "hub_nva" {
  name                  = "hub-nva-vm"
  location              = azurerm_resource_group.hub_nva.location
  resource_group_name   = azurerm_resource_group.hub_nva.name
  network_interface_ids = [azurerm_network_interface.hub_nva.id]
  vm_size               = var.vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "hubnvaosdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hub-nva-vm"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_virtual_machine_extension" "hub_nva" {
  name                 = "enable-iptables-routes"
  location             = azurerm_resource_group.hub_nva.location
  resource_group_name  = azurerm_resource_group.hub_nva.name
  virtual_machine_name = azurerm_virtual_machine.hub_nva.name
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "fileUris": [
        "https://raw.githubusercontent.com/mspnp/reference-architectures/master/scripts/linux/enable-ip-forwarding.sh"
        ],
        "commandToExecute": "bash enable-ip-forwarding.sh"
    }
  SETTINGS
}

resource "azurerm_route_table" "hub_gateway" {
  name                          = "hub-gateway-routing"
  location                      = azurerm_resource_group.hub_nva.location
  resource_group_name           = azurerm_resource_group.hub_nva.name
  disable_bgp_route_propagation = false

  route {
    name           = "toHub"
    address_prefix = "10.0.0.0/16"
    next_hop_type  = "VnetLocal"
  }

  route {
    name                   = "toSpoke1"
    address_prefix         = "10.1.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.0.36"
  }

  route {
    name                   = "toSpoke2"
    address_prefix         = "10.2.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.0.36"
  }
}

resource "azurerm_subnet_route_table_association" "hub_gateway" {
  subnet_id      = azurerm_subnet.hub_gateway.id
  route_table_id = azurerm_route_table.hub_gateway.id
  depends_on = ["azurerm_subnet.hub_gateway"]
}

resource "azurerm_route_table" "spoke1" {
  name                          = "spoke1-routing"
  location                      = azurerm_resource_group.hub_nva.location
  resource_group_name           = azurerm_resource_group.hub_nva.name
  disable_bgp_route_propagation = false

  route {
    name                   = "toSpoke2"
    address_prefix         = "10.2.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.0.36"
  }

  route {
    name           = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "vnetlocal"
  }
}

resource "azurerm_subnet_route_table_association" "spoke1_mgmt" {
  subnet_id      = azurerm_subnet.spoke1_mgmt.id
  route_table_id = azurerm_route_table.spoke1.id
  depends_on = ["azurerm_subnet.spoke1_mgmt"]
}

resource "azurerm_subnet_route_table_association" "spoke1_workload" {
  subnet_id      = azurerm_subnet.spoke1_workload.id
  route_table_id = azurerm_route_table.spoke1.id
  depends_on = ["azurerm_subnet.spoke1_workload"]
}

resource "azurerm_route_table" "spoke2" {
  name                          = "spoke2-routing"
  location                      = azurerm_resource_group.hub_nva.location
  resource_group_name           = azurerm_resource_group.hub_nva.name
  disable_bgp_route_propagation = false

  route {
    name                   = "toSpoke1"
    address_prefix         = "10.1.0.0/16"
    next_hop_in_ip_address = "10.0.0.36"
    next_hop_type          = "VirtualAppliance"
  }

  route {
    name           = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "vnetlocal"
  }
}

resource "azurerm_subnet_route_table_association" "spoke2_mgmt" {
  subnet_id      = azurerm_subnet.spoke2_mgmt.id
  route_table_id = azurerm_route_table.spoke2.id
  depends_on = ["azurerm_subnet.spoke2_mgmt"]
}

resource "azurerm_subnet_route_table_association" "spoke2_workload" {
  subnet_id      = azurerm_subnet.spoke2_workload.id
  route_table_id = azurerm_route_table.spoke2.id
  depends_on = ["azurerm_subnet.spoke2_workload"]
}

