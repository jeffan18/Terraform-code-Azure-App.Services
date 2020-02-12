output "databaseName" {

value = "${azurerm_mysql_database.fanfan.name}"
}


output "databaseServerName" {

value = "${azurerm_mysql_server.fanfan.fqdn}"
}
