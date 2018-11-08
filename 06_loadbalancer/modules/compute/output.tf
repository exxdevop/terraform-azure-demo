output "vpcs" {
  value = "${data.aws_vpcs.environment.ids[0]}"
}

output "subnets_public" {
  value = ["${data.aws_subnet.public.*.id}"]
}

output "subnets_private-app" {
  value = ["${data.aws_subnet.private-app.*.id}"]
}