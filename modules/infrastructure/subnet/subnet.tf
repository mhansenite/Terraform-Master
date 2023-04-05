variable "master" {}
variable "infa" {}
variable "my_vpc" {}

resource "aws_subnet" "resource_subnet_app" {
  count = length(var.infa.subnets_app)
  availability_zone = "${var.master.region}${var.infa.subnets_app[count.index].avl_zone}"
  assign_ipv6_address_on_creation                = "false"
  cidr_block                                     = var.infa.subnets_app[count.index].cidr_block
  #cidr_block                                     = each.value.cidr_block
  enable_resource_name_dns_a_record_on_launch    = "false"
  enable_resource_name_dns_aaaa_record_on_launch = "false"
  map_public_ip_on_launch                        = "false"
  private_dns_hostname_type_on_launch            = "ip-name"

  tags = {
    Name = "${var.infa.lane}-${var.infa.subnets_app[count.index].name}-SN"
    #Name = "${var.infa.lane}-${each.value.name}-SN"
  }

  tags_all = {
    Name = "${var.infa.lane}-${var.infa.subnets_app[count.index].name}-SN"
    #Name = "${var.infa.lane}-${each.value.name}-SN"
  }

  vpc_id = var.my_vpc.id
  
}

output "my_subnets_app" {
  value = aws_subnet.resource_subnet_app[*].id
}

resource "aws_subnet" "resource_subnet_db" {
  count = length(var.infa.subnets_db)
  availability_zone = "${var.master.region}${var.infa.subnets_app[count.index].avl_zone}"
  assign_ipv6_address_on_creation                = "false"
  cidr_block                                     = var.infa.subnets_db[count.index].cidr_block
  #cidr_block                                     = each.value.cidr_block
  enable_resource_name_dns_a_record_on_launch    = "false"
  enable_resource_name_dns_aaaa_record_on_launch = "false"
  map_public_ip_on_launch                        = "false"
  private_dns_hostname_type_on_launch            = "ip-name"

  tags = {
    Name = "${var.infa.lane}-${var.infa.subnets_db[count.index].name}-SN"
    #Name = "${var.infa.lane}-${each.value.name}-SN"
  }

  tags_all = {
    Name = "${var.infa.lane}-${var.infa.subnets_db[count.index].name}-SN"
    #Name = "${var.infa.lane}-${each.value.name}-SN"
  }

  vpc_id = var.my_vpc.id
  
}


output "my_subnets_db" {
  value = aws_subnet.resource_subnet_app[*].id
}