variable "master" {}
variable "conf" {}
variable "app" {}
variable "app_name" {}



data "aws_vpc" "my_vpc" {
  filter {
  name = "tag:Name"
  values = ["${var.conf.lane}-VPC"]

  }

}
data "aws_ec2_managed_prefix_list" "adm_prefix_id" {
    filter {
  name = "prefix-list-name"
  values = ["adm-app-zone-PL"]

  }
}
data "aws_ec2_managed_prefix_list" "lane_prefix_id" {
    filter {
  name = "prefix-list-name"
  values = ["${var.conf.lane}-app-zone-PL"]

  }
}

resource "aws_security_group" "resource_security_groups" {
  description = "Security group for specific app"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }
dynamic "ingress" {
    for_each = var.app.additional_zone_access_pl

    content {
      from_port       = var.app.external_port
      to_port         = var.app.external_port
      prefix_list_ids = [ ingress.value ]
      protocol  = "tcp"
    }
  }
  ingress {
    description     = "adm"
    from_port       = var.app.external_port
    prefix_list_ids = [ data.aws_ec2_managed_prefix_list.adm_prefix_id.id ]
    protocol        = "tcp"
    self            = "false"
    to_port         = var.app.external_port
  }

  ingress {
    description     = "apps"
    from_port       = var.app.external_port
   prefix_list_ids = [ data.aws_ec2_managed_prefix_list.lane_prefix_id.id ]
    protocol        = "tcp"
    self            = "false"
    to_port         = var.app.external_port
  }

  name = "${var.conf.lane}-app-${var.app_name}-Access-SG"

  tags = {
    Name = "${var.conf.lane}-app-${var.app_name}-Access-SG"
  }

  tags_all = {
    Name = "${var.conf.lane}-app-${var.app_name}-Access-SG"
  }

  vpc_id = data.aws_vpc.my_vpc.id
}

output "my_security_group_id" {
  value       = aws_security_group.resource_security_groups.id
}