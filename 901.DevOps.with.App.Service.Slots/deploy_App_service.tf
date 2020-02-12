provider "azurerm" { }

resource "azurerm_resource_group" "AppSlotFan" {
  name = "RG04-westus2-20200127"
  location = "westus2"
}

resource "azurerm_app_service_plan" "AppSlotFan" {
  name = "AppServicePlan-westus2-20200127"
  location = azurerm_resource_group.AppSlotFan.location
  resource_group_name = azurerm_resource_group.AppSlotFan.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "AppSlotFan" {
  name = "AppService-westus2-20200127"
  location = azurerm_resource_group.AppSlotFan.location
  resource_group_name = azurerm_resource_group.AppSlotFan.name
  app_service_plan_id = azurerm_app_service_plan.AppSlotFan.id
}

resource "azurerm_app_service_slot" "app-service-slot-fan" {
  name = "AppServiceSlot1-westus2-20200127"
  location = azurerm_resource_group.AppSlotFan.location
  resource_group_name = azurerm_resource_group.AppSlotFan.name
  app_service_plan_id = azurerm_app_service_plan.AppSlotFan.id
  app_service_name = azurerm_app_service.AppSlotFan.name
}
