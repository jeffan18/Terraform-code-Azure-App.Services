resource "azurerm_resource_group" "forvmss" {
 name     = var.resource_group_name
 location = var.location
 tags     = var.tags
}

resource "azurerm_virtual_network" "forvmss" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.forvmss.name
  tags                = var.tags
}

resource "azurerm_subnet" "subnet1forvmss" {
  name                 = var.vmss_subnet1_name
  resource_group_name  = azurerm_resource_group.forvmss.name
  virtual_network_name = azurerm_virtual_network.forvmss.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_subnet" "subnet2forvmss" {
  name                 = var.vmss_subnet2_name
  resource_group_name  = azurerm_resource_group.forvmss.name
  virtual_network_name = azurerm_virtual_network.forvmss.name
  address_prefix       = "10.0.2.0/24"
}

resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  number  = false
}

# the public IP is associated with a FQDN, with a random string
# the FQDN name will be: "vmss_publicip_fqdn", is saved in output.tf
resource "azurerm_public_ip" "forvmss" {
  name                         = var.public_ip_name
  location                     = var.location
  resource_group_name          = azurerm_resource_group.forvmss.name
  allocation_method = "Static"
  domain_name_label            = random_string.fqdn.result
  tags                         = var.tags
}

# Add LB definition for VMSS===
resource "azurerm_lb" "forvmss" {
  name                = var.vmss_lb_name
  location            = var.location
  resource_group_name = azurerm_resource_group.forvmss.name

  frontend_ip_configuration {
    name                 = "PublicIPforLBFrontEnd"
    public_ip_address_id = azurerm_public_ip.forvmss.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "forvmss" {
  name                = "BackEndAddressPool"
  resource_group_name = azurerm_resource_group.forvmss.name
  loadbalancer_id     = azurerm_lb.forvmss.id
}

resource "azurerm_lb_probe" "forvmss" {
  name                = "ProbeforSSH"
  resource_group_name = azurerm_resource_group.forvmss.name
  loadbalancer_id     = azurerm_lb.forvmss.id
  port                = var.application_port
}

resource "azurerm_lb_rule" "forvmss" {
  frontend_ip_configuration_name = "PublicIPforLBFrontEnd"
  resource_group_name            = azurerm_resource_group.forvmss.name
  loadbalancer_id                = azurerm_lb.forvmss.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = var.application_port
  backend_port                   = var.application_port
  backend_address_pool_id        = azurerm_lb_backend_address_pool.forvmss.id
  probe_id                       = azurerm_lb_probe.forvmss.id
}

# Add VMSS definition===
resource "azurerm_virtual_machine_scale_set" "forvmss" {
  name                = var.vm_scaleset_name
  location            = var.location
  resource_group_name = azurerm_resource_group.forvmss.name
  upgrade_policy_mode = "Manual"

  sku {
    name     = "Standard_DS1_v2"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun          = 0
    caching        = "ReadWrite"
    create_option  = "Empty"
    disk_size_gb   = 10
  }

  os_profile {
    computer_name_prefix = "vmss-staging-"
    admin_username       = var.admin_user
    admin_password       = var.admin_password
    custom_data          = file("web.conf")
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = azurerm_subnet.subnet2forvmss.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.forvmss.id]
      primary = true
    }
  }

  tags = var.tags
}
