variable "master" {}


resource "aws_route53_zone" "resource_route53_zone" {
  name          = "${var.master.domain}"
}


