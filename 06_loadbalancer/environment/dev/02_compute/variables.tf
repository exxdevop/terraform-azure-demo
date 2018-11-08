variable "region" {
}

variable "image" {
  default = {}
}

variable "instance_type_bastion" {}

variable "instance_type_appserver" {}

variable "key_name" {}

variable "lb_ip_address_type" {}