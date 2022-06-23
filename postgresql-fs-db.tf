resource "azurerm_postgresql_flexible_server_database" "Flex_Server_db" {
  name      = "flex_postgres"
  server_id = azurerm_postgresql_flexible_server.Post_Flex.id
  collation = "en_US.UTF8"
  charset   = "UTF8"
}