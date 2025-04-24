variable "location" {
  type        = string
  description = "The location where the resources will be created"
  default     = "West Europe"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
  default     = "my-eazy-rg"
}
variable "nsg_name" {
  type        = string
  description = "The name of the network security group"
  default     = "my-eazy-nsg"

}
variable "instance_template" {
  type        = string
  description = "Template for the webserver"
  default     = "Standard_D2_v2"
}

variable "environment" {
  type        = string
  description = "The environment for the resources"
  default     = "eazy-env"

}