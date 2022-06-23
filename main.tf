# Create a Module that contain vm machines
module "VM_MACHINES" {
  source    = "./VM_MACHINES"
  location  = var.resource_group_location
  resource  = var.resource_group_name
  subnet_id = azurerm_subnet.Sub_net.id
}
# Create a Resource_Group
resource "azurerm_resource_group" "Weight_Tracker_Production" {
  name     = var.resource_group_name
  location = var.resource_group_location
}
# Create a virtual network
resource "azurerm_virtual_network" "Vnet" {
  depends_on          = [azurerm_resource_group.Weight_Tracker_Production]
  name                = "vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
}
# Create a Subnet
resource "azurerm_subnet" "Sub_net" {
  name                 = "app_sub"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.Vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
# Create a Security_Group for Application
resource "azurerm_network_security_group" "Public_Nsg" {
  name                = "pub_nsg"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "85.65.209.24"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Dev"
  }

  security_rule {
    name                       = "web"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}
# Create a Security_Group for PostgresSQL
resource "azurerm_network_security_group" "NSG_PSQL" {
  name                = "nsg_psql"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "PORT_5432"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }
    security_rule {
      name                       = "postgres"
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "10.0.2.0/24"
      destination_address_prefix = "*"
    }
  }
# Create a Network_interface to security groups
resource "azurerm_network_interface_security_group_association" "public_assoc" {

  count                     = 3
  network_interface_id      = module.VM_MACHINES.nics_id[count.index]
  network_security_group_id = azurerm_network_security_group.Public_Nsg.id
}
# Create a Subnet for PostgresSQL
resource "azurerm_subnet" "PSQL_SUB" {
  name                 = "db_sub"
  virtual_network_name = azurerm_virtual_network.Vnet.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}
# Create public IPs
resource "azurerm_public_ip" "Pub_IP" {
  name                = "publicIPForLB"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}
# Create a Load_Balancer
resource "azurerm_lb" "LB" {
  name                = "loadBalancer"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "publicIPAddress"
    public_ip_address_id = azurerm_public_ip.Pub_IP.id

  }
}
# Create a Lb_nat_rule
resource "azurerm_lb_nat_rule" "lb_nat_rule" {
  count                          = 3
  depends_on                     = [azurerm_lb.LB]
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.LB.id
  name                           = "SSH_RULES${count.index}"
  protocol                       = "Tcp"
  frontend_port                  = 45000 + count.index
  backend_port                   = 22
  frontend_ip_configuration_name = "publicIPAddress"
}
# connect one of the frontend VMs to the NAT rule
resource "azurerm_network_interface_nat_rule_association" "NATAssociation" {
  count                 = 3
  ip_configuration_name = "IpConfiguration"
  nat_rule_id           = azurerm_lb_nat_rule.lb_nat_rule[count.index].id
  network_interface_id  = module.VM_MACHINES.nics_id[count.index]
}
# Create a Load_Balancer Probe
resource "azurerm_lb_probe" "lbProbe" {
  name                = "tcpProbe"
  loadbalancer_id     = azurerm_lb.LB.id
  protocol            = "Http"
  port                = 8080
  interval_in_seconds = 5
  number_of_probes    = 2
  request_path        = "/"

}
#load balancer rule
resource "azurerm_lb_rule" "LoadBlRule8080" {
  loadbalancer_id                = azurerm_lb.LB.id
  name                           = "port_8080"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "publicIPAddress"
  probe_id                       = azurerm_lb_probe.lbProbe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.Back_Pool.id]
  disable_outbound_snat          = true
}
# Create a Backend_Address_Pool
resource "azurerm_lb_backend_address_pool" "Back_Pool" {
  depends_on      = [azurerm_resource_group.Weight_Tracker_Production]
  loadbalancer_id = azurerm_lb.LB.id
  name            = "BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "NIBAPA" {
  count                   = 3
  backend_address_pool_id = azurerm_lb_backend_address_pool.Back_Pool.id
  ip_configuration_name   = "IpConfiguration"
  network_interface_id    = module.VM_MACHINES.nics_id[count.index]
}



