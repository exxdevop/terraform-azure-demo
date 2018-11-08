module "global_variables" {
  source = "./../00_global_variables"
}

module "networking" {
  source         = "./../../../modules/networking"
  environment    = "${module.global_variables.environment}"
  region         = "${var.region}"
  vpc_cidr_block = "${var.vpc_cidr_block}"
  subnet_bits    = "${var.subnet_bits}"
  azs            = "${var.azs}"
}
