# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "5e239f4e-eb80-45b5-8761-a929c6027e74"
  client_id       = "62c49c26-bc5d-4124-a743-b366a6422e8a"
  client_secret   = "98a47fe1-cc31-47a0-890a-28c6dec0c9c2"
  tenant_id       = "e0d97d0a-f46f-4a90-aeed-9b833108e7d5"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "fan_tf_group" {
  name = "RG02-eastus-20200122"
  location = "eastus"

  tags = {
    environment = "Fan Terraform Test"
  }
}

# Create virtual network
resource "azurerm_virtual_network" "fan_tf_network" {
  name                = "VNET01-eastus-20200122"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.fan_tf_group.name

  tags = {
    environment = "Fan Terraform Test"
  }
}

# Create subnet
resource "azurerm_subnet" "fan_tf_subnet03" {
  name                 = "Subnet03-eastus-20200122"
  resource_group_name  = azurerm_resource_group.fan_tf_group.name
  virtual_network_name = azurerm_virtual_network.fan_tf_network.name
  address_prefix       = "10.0.2.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "fan_tf_public_ip01" {
  name                         = "PublicIP01-eastus-20200122"
  location                     = "eastus"
  resource_group_name          = azurerm_resource_group.fan_tf_group.name
  allocation_method            = "Dynamic"
 
  tags = {
    environment = "Fan Terraform Test"
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "fan_tf_nsg01" {
  name                = "NSG01-eastus-20200122"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.fan_tf_group.name
    
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

  tags = {
    environment = "Fan Terraform Test"
  }
}

# Create network interface
resource "azurerm_network_interface" "fan_tf_nic01" {
  name                        = "NIC01-eastus-20200122"
  location                    = "eastus"
  resource_group_name         = azurerm_resource_group.fan_tf_group.name
  network_security_group_id   = azurerm_network_security_group.fan_tf_nsg01.id

  ip_configuration {
    name                          = "NIC01-conf-eastus-20200122"
    subnet_id                     = "${azurerm_subnet.fan_tf_subnet03.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.fan_tf_public_ip01.id}"
  }

  tags = {
    environment = "Fan Terraform Test"
  }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.fan_tf_group.name
  }
    
  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "fan_tf_diag_storage_account" {
  name                        = "diag${random_id.randomId.hex}"
  resource_group_name         = azurerm_resource_group.fan_tf_group.name
  location                    = "eastus"
  account_replication_type    = "LRS"
  account_tier                = "Standard"

  tags = {
    environment = "Fan Terraform Test"
  }
}

# Create virtual machine
resource "azurerm_virtual_machine" "fanvm01" {
  name                  = "VM01-eastus-20200122"
  location              = "eastus"
  resource_group_name   = azurerm_resource_group.fan_tf_group.name
  network_interface_ids = [azurerm_network_interface.fan_tf_nic01.id]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "VM01-OsDisk-eastus-20200122"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "fanhost01"
    admin_username = "elecview"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/elecview/.ssh/authorized_keys"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAovstHZOqDTjln8Oksv7Hlbcqg4ljPtl5t9ZH3kzdDVlobE76B+PL7h4yTDFevfuFICG1On08XeTC84JNKWSR6/uD1YKfcxNRYBcZTOXglX7yXFYXuCYLZoSiTPzmeGMJQ5UNZu8twnO3Fk6+lkZuA26/UgT+hs29P8AC+BWKDcnaoEwweVxuLF7RRlxt6wymoXnsCIYpmHAMg7h2zX5pOCTkuMRwIQ4S+4m/S/VlOVZqPYFvq936QiSJ68X2eJsSOLcRx2UXVC07q2Diqm/Y0foV1WTP7uzgcX/W9JscRpBquHf9s83g5hhSylltA1vGN3/DJaes1N3sguIJAmLuXQ=="
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = azurerm_storage_account.fan_tf_diag_storage_account.primary_blob_endpoint
  }

  tags = {
    environment = "Fan Terraform Test"
  }
}
