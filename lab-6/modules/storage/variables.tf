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
variable "storage_account_name" {
  type        = string
  description = "The name of the storage account"
  default     = "myeazytrainingstorage"
  validation {
    condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24
    error_message = "The storage account name must be between 3 and 24 characters long."
  }
  
}
