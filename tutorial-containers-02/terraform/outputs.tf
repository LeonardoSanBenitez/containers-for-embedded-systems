output "dps_rg" {
    value = azurerm_iothub_dps.main.resource_group_name
}

output "dps_name" {
    value = azurerm_iothub_dps.main.name
}
