variable "master" {}
variable "infa" {}


resource "aws_ec2_managed_prefix_list" "resource_prefix_list_app" {
  name           = "${var.infa.lane}-app-zone-PL"
  address_family = "IPv4"
  max_entries    = 5

  entry {
    cidr        = var.infa.subnets_app[0].cidr_block
    description = var.infa.subnets_app[0].name
  }

  entry {
    cidr        = var.infa.subnets_app[1].cidr_block
    description = var.infa.subnets_app[1].name
  }

  tags = {
    Env = "${var.infa.lane}-app-zone-PL"
  }
}


resource "aws_ec2_managed_prefix_list" "resource_prefix_list_db" {
  name           = "${var.infa.lane}-db-zone-PL"
  address_family = "IPv4"
  max_entries    = 5

  entry {
    cidr        = var.infa.subnets_db[0].cidr_block
    description = var.infa.subnets_db[0].name
  }

  entry {
    cidr        = var.infa.subnets_db[1].cidr_block
    description = var.infa.subnets_db[1].name
  }

  tags = {
    Env = "${var.infa.lane}-db-zone-PL"
  }
}

output "prefix_list_db" {
  value = aws_ec2_managed_prefix_list.resource_prefix_list_db
}

output "prefix_list_app" {
 value = aws_ec2_managed_prefix_list.resource_prefix_list_app
}

