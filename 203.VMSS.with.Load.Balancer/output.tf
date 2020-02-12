output "vmss_publicip_fqdn" {
     value = azurerm_public_ip.forvmss.fqdn
}

output "vmss_publicip_jumpbox_fqdn" {
     value = azurerm_public_ip.jumpbox.fqdn
}

