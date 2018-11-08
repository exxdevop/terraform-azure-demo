variable "environment" {}

variable "region" {}

/* Ubuntu Trusty 18.04 LTS (x64) */
variable "images" {
  type = "map"

  default = {
    eu-central-1 = "ami-0bdf93799014acdc4"
    eu-west-1    = "ami-00035f41c82244dab"
  }
}

variable "instance_type_bastion" {}

variable "instance_type_appserver" {}

variable "key_name" {}

variable "lb_ip_address_type" {}
