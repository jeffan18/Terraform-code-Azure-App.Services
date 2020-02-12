/* Azure Credentials for Terraform */
variable "subscription_id" {}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}


/* Project, environment, location */
variable "environment" {
default = "development"
}


variable "dns_prefix" {
default = "fan"
}


variable "project" {
default = "mysql"
}


variable "location" {
default = "East US"
}


locals {
mysql_server_name = "${var.dns_prefix}-${var.project}-${substr(var.environment, 0, 3)}-server01"
mysql_database_name = "${var.dns_prefix}-${var.project}-${substr(var.environment, 0, 3)}-db01"
}


/* Resources */
variable "resource_group_name" {
description = "resource group of the resources."
default = "RG-Fan-eastus-20200211"
}


/* MySQL Parameters */
variable "administratorLogin" {

description = "Database administrator login name"
default = "elecview"
}


variable "administratorLoginPassword" {

description = "Database administrator password"
default = "Miss9521"
}


variable "databaseDTU" {

description = "Azure database for MySQL pricing tier"
default = 2
}


variable "databaseSkuName" {

description = "Azure database for MySQL sku name"
default = "GP_Gen5_2"
}


variable "databaseSkuFamily" {

description = "Azure database for MySQL sku family"
default = "Gen5"
}


variable "databaseSkuSizeMB" {

description = "Azure database for MySQL Sku Size"
default = 5120
}


variable "databaseSkuTier" {

description = "Azure database for MySQL pricing tier"
default = "GeneralPurpose"
}


variable "mysqlVersion" {

description = "MySQL version"
default = "5.7"
}
