resource "azurerm_resource_group" "rg_aks" {
    name     = var.resource_group_name
    location = var.location
}

resource "random_id" "logsuffix" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "akslogws" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${var.log_analytics_workspace_name}-${random_id.logsuffix.dec}"
  location            = var.log_analytics_workspace_location
  resource_group_name = azurerm_resource_group.rg_aks.name
  sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "akslogsolution" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.akslogws.location
  resource_group_name   = azurerm_resource_group.rg_aks.name
  workspace_resource_id = azurerm_log_analytics_workspace.akslogws.id
  workspace_name        = azurerm_log_analytics_workspace.akslogws.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_kubernetes_cluster" "aks01" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg_aks.location
  resource_group_name = azurerm_resource_group.rg_aks.name
  dns_prefix          = var.dns_prefix

  linux_profile {
    admin_username = "elecview"
    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAovstHZOqDTjln8Oksv7Hlbcqg4ljPtl5t9ZH3kzdDVlobE76B+PL7h4yTDFevfuFICG1On08XeTC84JNKWSR6/uD1YKfcxNRYBcZTOXglX7yXFYXuCYLZoSiTPzmeGMJQ5UNZu8twnO3Fk6+lkZuA26/UgT+hs29P8AC+BWKDcnaoEwweVxuLF7RRlxt6wymoXnsCIYpmHAMg7h2zX5pOCTkuMRwIQ4S+4m/S/VlOVZqPYFvq936QiSJ68X2eJsSOLcRx2UXVC07q2Diqm/Y0foV1WTP7uzgcX/W9JscRpBquHf9s83g5hhSylltA1vGN3/DJaes1N3sguIJAmLuXQ=="
    }
  }


  default_node_pool {
    name            = "workerpool"
    node_count      = var.workernodes_count
    vm_size         = "Standard_DS1_v2"
  }

  service_principal {
        client_id     = var.client_id
        client_secret = var.client_secret
    }

  addon_profile {
    oms_agent {
    enabled    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.akslogws.id
    }
  }

  tags = {
    Environment = "Fan Terraform Test"
  }
}
