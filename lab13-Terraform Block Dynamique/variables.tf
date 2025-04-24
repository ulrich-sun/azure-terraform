variable "allowed_ports" {
  default = [8200, 8201, 8300, 9200, 9500, 22, 80, 443]
}
variable "instance_template" {
  type = string
  description = "Template for the webserver"
  default     = "Standard_D2_v2"
}

variable "location" {
  type        = string
  description = "Location for the resources"
  default     = "westeurope"
}