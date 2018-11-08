/*=== VARIABLES ===*/
variable "environment" {}

variable "region" {}

variable "vpc_cidr_block" {
  default = "10.42.0.0/16"
}

variable "subnet_bits" {
  default = "8"
}

variable "azs" {
  type = "map"

  default = {
    "eu-central-1" = "eu-central-1a,eu-central-1b,,eu-central-1c"
    "eu-west-1"    = "eu-west-1a,eu-west-1b,eu-west-1c"
  }
}

/*variable "nat" {
    type    = "map"
    default = {
        ami_image         = "unknown"
        instance_type     = "unknown"
        availability_zone = "unknown"
        key_name          = "unknown"
        filename          = "userdata_nat_asg.sh"
    }
}
*/


/*
variable "env_domain" {
    type    = "map"
    default = {
        name    = "unknown"
        zone_id = "unknown"
    }
}
*/

