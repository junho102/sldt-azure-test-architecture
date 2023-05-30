variable "prefix" {
  description = "project name"
  default = "sldt"
}

variable "environment" {
  default = "test"
}

variable "region" {
  default = "Korea Central"
}


### network ###
###############
variable "address_space" {
  description = "virtual network address space"
  default = "10.0.0.0/16"
}

variable "pub_subnet_prefix" {
  description = "public subnet address prefixes"
  default = "10.0.0.0/24"
}

variable "pri_subnet_prefix" {
  description = "private subnet address prefixes"
  default = "10.0.1.0/24"
}

### virtual machine ###
#######################
variable "image_publisher" {
  description = "Name of the publisher of the image (az vm image list)"
  default     = "Canonical"
}

variable "image_offer" {
  description = "Name of the offer (az vm image list)"
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  description = "Image SKU to apply (az vm image list)"
  default     = "22_04-lts"
}

variable "image_version" {
  description = "Version of the image to apply (az vm image list)"
  default     = "latest"
}

variable "vault_vm_num" {
  description = "number of vault vms"
  type = list(string)
  default = ["1", "2", "3"]
}

variable "vm_size" {
  type = list(string)
  default = ["Standard_DS1_v2", "Standard_D2s_v3", "Standard_B2ms"]
}

locals {
  vault_vm_num = toset(var.vault_vm_num)
}

variable "vm_username" {
  default = "adminuser"
}

### storage account ###
#######################
variable "storage_account_name" {
  description = "storage account name can only consist of lowercase letters and numbers, and must be between 3 and 24 characters long"
  default = ""
}

variable "azurerm_storage_container_name" {
  description = "blob storage container name"
  default = "vaultdatabackup"
}

variable "container_access_type" {
  default = "private"
}

### key vault ###
#################
variable "tenant_id" {
  default = ""
}

variable "client_id" {
  default = ""
}

variable "key_name" {
  description = "key name in azure key vault"
  default = "vault-key"
}


### container registry ###
##########################
variable "container_registry_name" {
  default = "sldtljhacr"
}


### aks ###
###########
variable "client_secret" {
  default = ""
}

variable "kubernetes_version" {
  default = "1.25.6"
}

variable "dns_prefix" {
  description = "dns prefix must be unique"
  default = ""
}



