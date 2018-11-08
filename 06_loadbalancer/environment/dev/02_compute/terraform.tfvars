region = "eu-central-1"

/* Ubuntu Trusty 16.04 LTS (x64) */
image = {
  "eu-central-1" = "ami-086a09d5b9fa35dc7"
  "eu-west-1" = "ami-0773391ae604c49a4"
}

instance_type_bastion = "t2.nano"

instance_type_appserver = "t2.micro"

key_name = "AWS_KEY_TESTLAB"

lb_ip_address_type = "ipv4"