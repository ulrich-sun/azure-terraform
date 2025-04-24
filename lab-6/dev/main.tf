
#update des modules pour le dev et le prod
module "rg" {
  source              = "../modules/rg"
  location            = var.location
  resource_group_name = var.resource_group_name

}
module "ip" {
  source              = "../modules/ip"
  location            = module.rg.rg_location
  resource_group_name = module.rg.rg_name

}

module "nsg" {
  source              = "../modules/nsg"
  location            = module.rg.rg_location
  resource_group_name = module.rg.rg_name
  nsg_name            = var.nsg_name

}
module "network" {
  source              = "../modules/network"
  location            = module.rg.rg_location
  resource_group_name = module.rg.rg_name
  public_ip_id        = module.ip.public_ip_id
  nsg_id              = module.nsg.nsg_id

}


module "instance" {
  source               = "../modules/instance"
  location             = module.rg.rg_location
  resource_group_name  = module.rg.rg_name
  network_interface_id = module.network.network_interface_id
  instance_template    = var.instance_template

}
module "storage" {
  source               = "../modules/storage"
  location             = module.rg.rg_location
  resource_group_name  = module.rg.rg_name
  storage_account_name = var.storage_account_name

}
