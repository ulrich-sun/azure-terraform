variable "resource_group_name" {
  description = "Nom du groupe de ressources"
  type        = string
  default     = "tfeazytraining-rg"
}

variable "location" {
  description = "Emplacement Azure"
  type        = string
  default     = "West Europe"
}

variable "web_server_port" {
  type    = number
  default = 80
}

variable "ssh_server_port" {
  type    = number
  default = 22
}

variable "instance_template" {
  type    = string
  default = "Standard_B1s"
}

variable "admin_password" {
  description = "Mot de passe de l'utilisateur admin"
  type        = string
  sensitive   = true
}

variable "storage_account_name" {
  description = "storage account"
  type        = string
  default     = "eazytrainingstorage23"
}
variable "storage_container_name" {
  description = "Nom du conteneur de stockage"
  type        = string
  default     = "eazytraining-container"
}
variable "container_access_type" {
  description = "Type d'accès du conteneur (private, blob ou container)"
  type        = string
  default     = "private"
}
