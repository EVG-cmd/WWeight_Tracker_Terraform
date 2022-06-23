output "nics_id" {
  value = azurerm_network_interface.NIC.*.id
}
