variable "master" {}
variable "my_vpc_id" {}


data "aws_route53_zone" "aws_master_domain" {
  name         = var.master.domain
  private_zone = true
}


resource "aws_route53_zone_association" "vpc_route53_associatoin" {
  zone_id = data.aws_route53_zone.aws_master_domain.zone_id
  vpc_id  = var.my_vpc_id
}
