provider "azurerm" { }

# Swap the production slot and the staging slot
resource "azurerm_app_service_active_slot" "SwapActiveSlot" {
    resource_group_name   = "RG04-westus2-20200127"
    app_service_name      = "AppService-westus2-20200127"
    app_service_slot_name = "AppServiceSlot1-westus2-20200127"
}
