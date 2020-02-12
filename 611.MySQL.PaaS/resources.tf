resource "azurerm_resource_group" "fanfan" {
name = var.resource_group_name
location = var.location
}


resource "azurerm_mysql_server" "fanfan" {

name = local.mysql_server_name
location = azurerm_resource_group.fanfan.location
resource_group_name = azurerm_resource_group.fanfan.name

administrator_login = "${var.administratorLogin}"
administrator_login_password = "${var.administratorLoginPassword}"
version = "${var.mysqlVersion}"
ssl_enforcement = "Disabled"
sku {
name = "${var.databaseSkuName}"
capacity = "${var.databaseDTU}"
tier = "${var.databaseSkuTier}"
family = "${var.databaseSkuFamily}"
}
storage_profile {

storage_mb = "${var.databaseSkuSizeMB}"
}
}


resource "azurerm_mysql_database" "fanfan" {

name = local.mysql_database_name
resource_group_name = azurerm_resource_group.fanfan.name

server_name = azurerm_mysql_server.fanfan.name
charset = "utf8"
collation = "utf8_unicode_ci"
}
