variable "master" {}
variable "conf" {}
variable "app" {}
variable "app_name" {}

data "aws_lb" "data_elb" {
  name = "${var.conf.lane}-${var.app.lb_connect}-LB"
}

data "aws_route53_zone" "data_route53_zone" {
  name         = var.app.domain
  //private_zone = var.app.internal_lb // might be able to enable this once we are live with route53 for our domains .. for now it needs to always be true. 
  private_zone = "true"
}


resource "aws_route53_record" "resource_route53_reccord" {
  name    = "${var.conf.lane}-${var.app_name}.${var.app.domain}"
  records = [ "${data.aws_lb.data_elb.dns_name}" ]
  ttl     = "3600"
  type    = "CNAME"
  zone_id = data.aws_route53_zone.data_route53_zone.id
}




output "my_lb" {
  value       = data.aws_lb.data_elb
}

output "my_zone" {
  value       = data.aws_route53_zone.data_route53_zone
}