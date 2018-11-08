module "global_variables" {
  source = "./../00_global_variables"
}

module "compute" {
  source                   = "./../../../modules/compute"
  environment              = "${module.global_variables.environment}"
  region                   = "${var.region}"
  images                   = "${var.image}"
  instance_type_bastion    = "${var.instance_type_bastion}"
  instance_type_appserver  = "${var.instance_type_appserver}"
  key_name                 = "${var.key_name}"
  lb_ip_address_type       = "${var.lb_ip_address_type}"
}
