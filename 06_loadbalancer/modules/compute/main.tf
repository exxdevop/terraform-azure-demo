# Sources:
# https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/tree/master/examples/basic


/******************/
/*  DATA SOURCES  */
/******************/

data "aws_vpcs" "environment" {
  tags {
    Environment = "${lower(var.environment)}"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = "${data.aws_vpcs.environment.ids[0]}"
  tags {
    Environment = "${lower(var.environment)}"
    Network     = "public"
  }
}

data "aws_subnet" "public" {
  count = "${length(data.aws_subnet_ids.public.ids)}"
  id    = "${data.aws_subnet_ids.public.ids[count.index]}"
}

data "aws_subnet_ids" "private-app" {
  vpc_id = "${data.aws_vpcs.environment.ids[0]}"
  tags {
    Environment = "${lower(var.environment)}"
    Network     = "private"
    Tier        = "app"
  }
}

data "aws_subnet" "private-app" {
  count = "${length(data.aws_subnet_ids.private-app.ids)}"
  id    = "${data.aws_subnet_ids.private-app.ids[count.index]}"
}


/***************/
/*  RESOURCES  */
/***************/

# Security Groups

resource "aws_security_group" "bastion" {
  name        = "${lower(var.environment)}-bastion"
  description = "Rules for bastion"
  vpc_id      = "${data.aws_vpcs.environment.ids[0]}"

  tags {
    Name = "${lower(var.environment)}-bastion"
  }
}

resource "aws_security_group_rule" "in-ssh-bastion-from-internet" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "out-ssh-bastion-to-appserver" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8"]
  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "out-http-bastion-to-internet" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "out-https-bastion-to-internet" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group" "appserver" {
  name        = "${lower(var.environment)}-appserver"
  description = "Rules for appserver"
  vpc_id      = "${data.aws_vpcs.environment.ids[0]}"
  tags {
    Name = "${lower(var.environment)}-appserver"
  }
}

resource "aws_security_group_rule" "in-ssh-appserver-from-bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = "${aws_security_group.bastion.id}"
  security_group_id = "${aws_security_group.appserver.id}"
}

resource "aws_security_group_rule" "in-http-appserver-from-lb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = "${aws_security_group.lb.id}"
  security_group_id = "${aws_security_group.appserver.id}"
}

resource "aws_security_group_rule" "out-http-appserver-to-internet" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.appserver.id}"
}

resource "aws_security_group_rule" "out-https-appserver-to-internet" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.appserver.id}"
}

resource "aws_security_group" "lb" {
  name        = "${lower(var.environment)}-lb"
  description = "Rules for loadbalancer"
  vpc_id      = "${data.aws_vpcs.environment.ids[0]}"
  tags {
    Name = "${lower(var.environment)}-lb"
  }
}

resource "aws_security_group_rule" "in-http-lb-from-internet" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.lb.id}"
}

resource "aws_security_group_rule" "out-http-lb-to-appserver" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8"]
  security_group_id = "${aws_security_group.lb.id}"
}

# EC2 instances

resource "aws_instance" "bastion" {
  ami                         = "${lookup(var.images, var.region)}"
  instance_type               = "${var.instance_type_bastion}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${data.aws_subnet.public.0.id}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]
  tags {
    Name = "${lower(var.environment)}-bastion"
  }
}

resource "aws_instance" "appserver" {
  ami                         = "${lookup(var.images, var.region)}"
  instance_type               = "${var.instance_type_appserver}"
  key_name                    = "${var.key_name}"
  # no high availability:
  # ---------------------
  # subnet_id                   = "${data.aws_subnet.private-app.0.id}"
  #
  # no dynamic subnets:
  # -------------------
  # subnet_id                   = "${element(list("${data.aws_subnet.private-app.0.id}", "${data.aws_subnet.private-app.1.id}"), count.index)}"
  #
  # best solution: (https://github.com/hashicorp/terraform/issues/3234)
  # -------------------------------------------------------------------
  subnet_id                   = "${data.aws_subnet_ids.private-app.ids[count.index]}"
  associate_public_ip_address = false
  vpc_security_group_ids      = ["${aws_security_group.appserver.id}"]
  user_data = <<-EOF
                  #!/bin/bash
                  apt update -y && apt install apache2 -y
                  cat > /var/www/html/index.html<<'_END'
                  <h1>Environment: ${lower(var.environment)}</h1>
                  <p>Node: ${lower(var.environment)}-appserver-${count.index + 1}</p>
                  _END
                  systemctl start apache2.service
                  systemctl enable apache2.service
                  EOF
  tags {
    Name = "${lower(var.environment)}-appserver-${count.index + 1}"
  }
  # as many appserver as subnets
  count = "${length(data.aws_subnet_ids.private-app.ids)}"
}


# Loadbalancer

resource "aws_lb" "application_no_logs" {
  load_balancer_type               = "application"
  name                             = "${lower(var.environment)}-lb"
  internal                         = false
  security_groups                  = ["${aws_security_group.lb.id}"]
  subnets                          = ["${data.aws_subnet_ids.public.ids}"]
  ip_address_type                  = "${var.lb_ip_address_type}"
  tags {
    Name = "${lower(var.environment)}-lb"
  }
}

resource "aws_lb_target_group" "main_no_logs" {
  name                 = "${lower(var.environment)}-lb-target-group"
  vpc_id               = "${data.aws_vpcs.environment.ids[0]}"
  port                 = "80"
  protocol             = "HTTP"
  target_type          = "instance"
  health_check {
    interval            = "30"
    path                = "/"
    port                = "80"
    healthy_threshold   = "3"
    unhealthy_threshold = "2"
    timeout             = "5"
    protocol            = "HTTP"
    matcher             = "200"
  }
  tags {
    Name = "${lower(var.environment)}-lb-target-group"
  }
  depends_on = ["aws_lb.application_no_logs"]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "main_no_logs_to_appserver" {
  target_group_arn = "${aws_lb_target_group.main_no_logs.arn}"
  target_id        = "${element(aws_instance.appserver.*.id, count.index)}"
  port             = "80"
  # as many attachments as subnets
  count = "${length(data.aws_subnet_ids.private-app.ids)}"
}

resource "aws_lb_listener" "frontend_http_tcp_no_logs" {
  load_balancer_arn = "${aws_lb.application_no_logs.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.main_no_logs.arn}"
    type             = "forward"
  }
}