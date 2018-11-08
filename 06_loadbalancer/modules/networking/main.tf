/***************/
/*  RESOURCES  */
/***************/

resource "aws_vpc" "environment" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name        = "${var.environment}-vpc"
    Environment = "${lower(var.environment)}"
  }
}

resource "aws_internet_gateway" "environment" {
  vpc_id = "${aws_vpc.environment.id}"

  tags {
    Name        = "${var.environment}-internet-gateway"
    Environment = "${lower(var.environment)}"
  }
}

resource "aws_subnet" "public-subnets" {
  vpc_id            = "${aws_vpc.environment.id}"
  count             = "${length(split(",", lookup(var.azs, var.region)))}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr_block, var.subnet_bits, count.index)}"
  availability_zone = "${element(split(",", lookup(var.azs, var.region)), count.index)}"

  tags {
    Name        = "${var.environment}-public-subnet-${count.index}"
    Environment = "${lower(var.environment)}"
    Network     = "public"
  }

  map_public_ip_on_launch = true
}

resource "aws_subnet" "private-subnets-app" {
  vpc_id            = "${aws_vpc.environment.id}"
  count             = "${length(split(",", lookup(var.azs, var.region)))}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr_block, var.subnet_bits, count.index + length(split(",", lookup(var.azs, var.region))))}"
  availability_zone = "${element(split(",", lookup(var.azs, var.region)), count.index)}"

  tags {
    Name        = "${var.environment}-private-subnet-app-${count.index}"
    Environment = "${lower(var.environment)}"
    Network     = "private"
    Tier        = "app"
  }
}

resource "aws_subnet" "private-subnets-db" {
  vpc_id            = "${aws_vpc.environment.id}"
  count             = "${length(split(",", lookup(var.azs, var.region)))}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr_block, var.subnet_bits, count.index + (2 * length(split(",", lookup(var.azs, var.region)))))}"
  availability_zone = "${element(split(",", lookup(var.azs, var.region)), count.index)}"

  tags {
    Name        = "${var.environment}-private-subnet-db-${count.index}"
    Environment = "${lower(var.environment)}"
    Network     = "private"
    Tier        = "db"
  }
}

/* Routing einrichten */
resource "aws_route_table" "public-subnet" {
  vpc_id = "${aws_vpc.environment.id}"

  /* wenn route innerhalb der routing tabelle gesetzt wird, kann sie nicht mehr mittels terraform geloescht werden
                        route {
                            cidr_block = "0.0.0.0/0"
                            gateway_id = "${aws_internet_gateway.environment.id}"
                        }*/
  tags {
    Name        = "${var.environment}-public-subnet-route-table"
    Environment = "${lower(var.environment)}"
  }
}

resource "aws_route" "internet_public" {
  route_table_id         = "${aws_route_table.public-subnet.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.environment.id}"
}

resource "aws_route_table_association" "public-subnet" {
  count          = "${length(split(",", lookup(var.azs, var.region)))}"
  subnet_id      = "${element(aws_subnet.public-subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-subnet.id}"
}

resource "aws_route_table" "private-subnet" {
  vpc_id = "${aws_vpc.environment.id}"

  tags {
    Name        = "${var.environment}-private-subnet-route-table"
    Environment = "${lower(var.environment)}"
  }
}

resource "aws_route_table_association" "private-subnet-app" {
  count          = "${length(split(",", lookup(var.azs, var.region)))}"
  subnet_id      = "${element(aws_subnet.private-subnets-app.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-subnet.id}"
}

# resource "aws_route_table" "private-subnet-db" {
#   vpc_id = "${aws_vpc.environment.id}"

#   tags {
#     Name        = "${var.environment}-private-subnet-db-route-table"
#     Environment = "${lower(var.environment)}"
#   }
# }

resource "aws_route_table_association" "private-subnet-db" {
  count          = "${length(split(",", lookup(var.azs, var.region)))}"
  subnet_id      = "${element(aws_subnet.private-subnets-db.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-subnet.id}"
}

resource "aws_eip" "nat" {
  vpc      = true
}

resource "aws_nat_gateway" "environment" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public-subnets.0.id}"

  tags {
    Name        = "${var.environment}-nat-gateway"
    Environment = "${lower(var.environment)}"
  }
  depends_on = ["aws_eip.nat"]
}

resource "aws_route" "internet_private" {
  route_table_id         = "${aws_route_table.private-subnet.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_nat_gateway.environment.id}"
  depends_on             = ["aws_nat_gateway.environment"]
}