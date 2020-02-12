resource "azurerm_resource_group" "fanfan" {
 name = var.resource_group_name
 location = var.location
}

# VNet
resource "azurerm_virtual_network" "fanfan" {
  name                = var.vnet_name
  location            = azurerm_resource_group.fanfan.location
  resource_group_name = azurerm_resource_group.fanfan.name
  address_space       = ["${var.vnet_address_space}"]
}

# Subnets
resource "azurerm_subnet" "aks" {
  name                 = "${var.vnet_name}-aks-subnet"
  resource_group_name = azurerm_resource_group.fanfan.name
  address_prefix       = var.subnet_aks
  virtual_network_name = "${azurerm_virtual_network.fanfan.name}"
}

/* AAD - Application, Service Principle, Role Assignment*/
resource "azuread_application" "fanfan" {
  name = "${var.project}-${var.environment}-20200211"
}

resource "azuread_service_principal" "fanfan" {
  application_id = "${azuread_application.fanfan.application_id}"
}

resource "random_string" "password" {
  length  = 32
  special = true
}

resource "azuread_service_principal_password" "fanfan" {
  service_principal_id = "${azuread_service_principal.fanfan.id}"
  value                = "${random_string.password.result}"
  end_date             = "2099-01-01T01:00:00Z"
}

resource "azurerm_role_assignment" "fanfan" {
  scope                = "${data.azurerm_subscription.current.id}/resourceGroups/${azurerm_resource_group.fanfan.name}"
  role_definition_name = "Network Contributor"
  principal_id         = "${azuread_service_principal.fanfan.id}"
}

/* Log Analysis */
resource "azurerm_application_insights" "fanfan" {
  name                = "${var.project}-${var.environment}-insight"
  location            = "${azurerm_resource_group.fanfan.location}"
  resource_group_name = "${azurerm_resource_group.fanfan.name}"
  application_type    = "Web"
}

resource "azurerm_log_analytics_workspace" "fanfan" {
  name                = "${var.project}-${var.environment}-workspace"
  location            = "${azurerm_resource_group.fanfan.location}"
  resource_group_name = "${azurerm_resource_group.fanfan.name}"
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_log_analytics_solution" "fanfan" {
  solution_name         = "ContainerInsights"
  location              = "${azurerm_log_analytics_workspace.fanfan.location}"
  resource_group_name   = "${azurerm_resource_group.fanfan.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.fanfan.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.fanfan.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}


/* AKS definition, enabling AAD */
resource "azurerm_kubernetes_cluster" "fanfan" {
  name                = local.kubernetes_cluster_name
  location            = azurerm_resource_group.fanfan.location
  resource_group_name = azurerm_resource_group.fanfan.name
  dns_prefix          = "${var.dns_prefix}-${var.project}-${substr(var.environment, 0, 3)}"
  depends_on          = ["azurerm_role_assignment.fanfan"]
  
  agent_pool_profile {
    name            = "default"
    count           = "${var.node_count}"
    vm_size         = "${var.node_type}"
    os_type         = var.node_os
    os_disk_size_gb = 30
    vnet_subnet_id  = "${azurerm_subnet.aks.id}"
  }

  service_principal {
    client_id     = "${azuread_application.fanfan.application_id}"
    client_secret = "${azuread_service_principal_password.fanfan.value}"
  }

  role_based_access_control {
    enabled = true
  }

  network_profile {
    network_plugin = "azure"
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = "${azurerm_log_analytics_workspace.fanfan.id}"
    }
  }
}
