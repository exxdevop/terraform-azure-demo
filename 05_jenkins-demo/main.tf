resource "aws_vpc" "jenkins-demo" {
  cidr_block           = "10.99.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags {
    Name = "jenkins-demo-vpc"
  }
}

#resource "aws_internet_gateway" "jenkins-demo" {
#  vpc_id = "${aws_vpc.jenkins-demo.id}"
#  tags {
#    Name        = "jenkins-demo-igw"
#  }
#}