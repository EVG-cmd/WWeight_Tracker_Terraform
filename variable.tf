
#Variable "Resource_group_name
variable "resource_group_name" {
  description = "Name of the resource group in which the resources will be created"
  default     = "Weight_Tracker_Production"
}

#Varible of Resource_group_location
variable "resource_group_location" {
  default       = "westus 2"
  description   = "Location of the resource group."
}

#Varible of Resource_group_Virtual_Network
variable "resource_group_virtual_network" {
  default = "vnet"
}

variable "nics_ip" {
  default = "nics"
}

