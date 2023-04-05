variable "master" {}
variable "conf" {}
variable "app" {}
variable "app_name" {}

locals{
  skip_adm = var.conf.lane == "adm" ? [] : [1]
}
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
   lifecycle { ignore_changes = all }
   
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
      from_port       = tonumber(ingress.key)
      to_port         = tonumber(ingress.key) 
      prefix_list_ids = [ ingress.value ]
      protocol  = "tcp"
    }
  }
  dynamic ingress {
    for_each = local.skip_adm[*]
    content {
      description     = "adm"
      from_port       = var.app.external_port
      protocol        = "tcp"
      to_port         = var.app.external_port
      prefix_list_ids = [data.aws_ec2_managed_prefix_list.adm_prefix_id.id]
    }
  }
  ingress {
    description     = "${var.conf.lane}-apps"
    from_port       = var.app.external_port
    protocol        = "tcp"
    to_port         = var.app.external_port
    prefix_list_ids = [ data.aws_ec2_managed_prefix_list.lane_prefix_id.id ]
  }
  ingress {
    description     = "ssh"
    from_port       = 22
    cidr_blocks = [ "0.0.0.0/0" ]
    protocol        = "tcp"
    self            = "false"
    to_port         = 22
  }

  name = "${var.conf.lane}-app-${var.app_name}-Access-SG"

  tags = {
    Name = "${var.conf.lane}-app-${var.app_name}-Access-SG"
    env = var.conf.lane
    use = var.app.app_use
  }

  tags_all = {
    Name = "${var.conf.lane}-app-${var.app_name}-Access-SG"
    env = var.conf.lane
    use = var.app.app_use
  }

  vpc_id = data.aws_vpc.my_vpc.id 
}

output "my_security_group_id" {
  value       = aws_security_group.resource_security_groups.id
}