resource "azurerm_resource_group" "test" {
  name     = "RG-Fan-westus2-20200128"
  location = "West US 2"
}

resource "azurerm_virtual_network" "test" {
  name                = "VNet-Fan-westus2-20200128"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "Subnet02-in-VNet-Fan-westus2-20200128"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.2.0/24"
}

# Add code to the same Terraform configuration file to define a load balancer
resource "azurerm_public_ip" "test" {
  name                         = "PublicIP1-for-LB1-Fan-westus2-20200128"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  allocation_method            = "Static"
}

resource "azurerm_lb" "test" {
  name                = "LB1-Fan-westus2-20200128"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name                 = "publicIPAddress-for-LB1-Fan-westus2-20200128"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_lb_backend_address_pool" "test" {
  resource_group_name = azurerm_resource_group.test.name
  loadbalancer_id     = azurerm_lb.test.id
  name                = "BackEndAddressPool-for-LB1-Fan-westus2-20200128"
}

resource "azurerm_network_interface" "test" {
  count               = 2
  name                = "NIC${count.index}-Fan-westus2-20200128"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "NicIpConfiguration"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "dynamic"
    load_balancer_backend_address_pools_ids = [azurerm_lb_backend_address_pool.test.id]
  }
}

# Add code to the same Terraform configuration file to define 2 * Linux VMs
resource "azurerm_managed_disk" "test" {
  count                = 2
  name                 = "datadisk_${count.index}"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "100"
}

resource "azurerm_availability_set" "test" {
  name                         = "VMSet1-Fan-westus2-20200128"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_virtual_machine" "test" {
  count                 = 2
  name                  = "VM${count.index}-Fan-westus2-20200128"
  location              = azurerm_resource_group.test.location
  availability_set_id   = azurerm_availability_set.test.id
  resource_group_name   = azurerm_resource_group.test.name
  network_interface_ids = [element(azurerm_network_interface.test.*.id, count.index)]
  vm_size               = "Standard_DS1_v2"

  # Comment this line to keep the  disks (OS and data) automatically when deleting the VM
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

 # Optional data disks - additional
  storage_data_disk {
    name              = "datadisk_add_${count.index}"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "200"
  }

  storage_data_disk {
    name            = element(azurerm_managed_disk.test.*.name, count.index)
    managed_disk_id = element(azurerm_managed_disk.test.*.id, count.index)
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = element(azurerm_managed_disk.test.*.disk_size_gb, count.index)
  }

  os_profile {
    computer_name  = "fanserver${count.index}"
    admin_username = "elecview"
    admin_password = "Miss9521"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "staging"
  }
}

