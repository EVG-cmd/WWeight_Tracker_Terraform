resource "azurerm_subnet_network_security_group_association" "Sub_Nsg" {
  subnet_id                 = azurerm_subnet.PSQL_SUB.id
  network_security_group_id = azurerm_network_security_group.Public_Nsg.id
}
resource "azurerm_subnet_network_security_group_association" "Sub_Nsg_app" {
  subnet_id                 = azurerm_subnet.Sub_net.id
  network_security_group_id = azurerm_network_security_group.Public_Nsg.id
}
# Create a DNS Zone
resource "azurerm_private_dns_zone" "dns" {
  name                = "tracker.postgres.database.azure.com"
  resource_group_name = var.resource_group_name


  depends_on = [azurerm_subnet_network_security_group_association.Sub_Nsg]
}
# Create a Private Dns Zone
resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "dns_link"
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = azurerm_virtual_network.Vnet.id
  resource_group_name   = var.resource_group_name
}

resource "azurerm_postgresql_flexible_server" "Post_Flex" {
  name                   = "flex-postgres"
  resource_group_name    = var.resource_group_name
  location               = var.resource_group_location
  version                = "13"
  delegated_subnet_id    = azurerm_subnet.PSQL_SUB.id
  private_dns_zone_id    = azurerm_private_dns_zone.dns.id

  administrator_login    = var.administrator_login #The username was created in pass var. and not upload to Git Repo.
  administrator_password = var.administrator_password #The Password was created in pass var. and not upload to Git Repo.
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2s_v3"
  backup_retention_days  = 7

  depends_on = [azurerm_private_dns_zone_virtual_network_link.dns_link]
}

resource "azurerm_postgresql_flexible_server_configuration" "postgres_configuration" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.Post_Flex.id
  value     = "off"

}

