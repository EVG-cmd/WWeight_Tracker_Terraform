# Create a Network_Interface
resource "azurerm_network_interface" "NIC" {
  count               = 3
  name                = "nic${count.index}"
  location            = var.location
  resource_group_name = var.resource
  ip_configuration {
    name                                   = "IpConfiguration"
    subnet_id                              = var.subnet_id
    private_ip_address_allocation          = "Dynamic"
  }
}
# Create a Avavilability Set
resource "azurerm_availability_set" "AVSET_US" {
  name                         = "avset_us"
  location                     = var.location
  resource_group_name          = var.resource
  platform_fault_domain_count  = 3
  platform_update_domain_count = 3
  managed                      = true
}
# Create virtual machine
resource "azurerm_virtual_machine" "VM_APP" {
  count                 = 3
  name                  = "vm${count.index}"
  location              = var.location
  availability_set_id   = azurerm_availability_set.AVSET_US.id
  resource_group_name   = var.resource
  network_interface_ids = [element(azurerm_network_interface.NIC.*.id, count.index)]
  vm_size               = "Standard_D2as_v4"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    offer     = "0001-com-ubuntu-server-focal"
    publisher = "Canonical"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_profile {
    computer_name  = "app${count.index}"
    admin_username = var.admin_username #The username was created in pass var. and not upload to Git Repo.
    admin_password = var.admin_password #The Password was created in pass var. and not upload to Git Repo.
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  storage_os_disk {
    name              = "osdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"


  }
}

