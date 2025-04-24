variable "instance_template" {
  type        = string
  description = "Template for the webserver"
  default     = "Standard_D2_v2"
}
variable "location" {
  type        = string
  description = "The location where the resources will be created"
  default     = "West Europe"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
  default     = "my-eazytraining-rg"
}
variable "network_interface_id" {
  type        = string
  description = "The ID of the network interface to associate with the instance"
  default     = ""
  
}