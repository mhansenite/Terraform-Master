variable "masterMain" {}
variable "prd_vars" {}
variable "stg_vars" {}

//####################################################
//prd
//###################################################
data "aws_vpc" "data_prd_vpc" {
  cidr_block = var.prd_vars.vpc_cidr_block
}

data "aws_route_table" "resource_route_table_prd" {
  vpc_id = data.aws_vpc.data_prd_vpc.id
  tags   = {
    Name = "${var.prd_vars.lane}-RT"
  }
}


//####################################################
//stg
//###################################################
data "aws_vpc" "data_stg_vpc" {
  cidr_block = var.stg_vars.vpc_cidr_block
}

data "aws_route_table" "resource_route_table_stg" {
  vpc_id = data.aws_vpc.data_stg_vpc.id
  tags = {
    Name = "${var.stg_vars.lane}-RT"
  }
}

//////////////////////////////////////////////////
//stg<->prd
resource "aws_vpc_peering_connection" "resource_stg_prd_peering" {
  accepter {
    # allow_classic_link_to_remote_vpc = "false"
    allow_remote_vpc_dns_resolution  = "false"
    # allow_vpc_to_remote_classic_link = "false"
  }

  peer_owner_id = var.masterMain.aws_account_id
  peer_vpc_id   = data.aws_vpc.data_prd_vpc.id
  auto_accept = "true"

  requester {
    # allow_classic_link_to_remote_vpc = "false"
    allow_remote_vpc_dns_resolution  = "false"
    # allow_vpc_to_remote_classic_link = "false"
  }

  tags = {
    Name = "stg<->prd"
  }

  tags_all = {
    Name = "stg<->prd"
  }

  vpc_id = data.aws_vpc.data_stg_vpc.id
}

resource "aws_route" "resource_route_stg_prd" {
    route_table_id = data.aws_route_table.resource_route_table_prd.id
    destination_cidr_block             = var.stg_vars.vpc_cidr_block
    egress_only_gateway_id = null
    gateway_id             = null
    destination_ipv6_cidr_block        = null
    nat_gateway_id         = null
    network_interface_id   = null
    transit_gateway_id     = null
    vpc_peering_connection_id = aws_vpc_peering_connection.resource_stg_prd_peering.id
    
    # lifecycle {
    #   ignore_changes =  all 
    # }
}
resource "aws_route" "resource_route_prd_stg" {
    route_table_id = data.aws_route_table.resource_route_table_stg.id
    destination_cidr_block             = var.prd_vars.vpc_cidr_block
    egress_only_gateway_id = null
    gateway_id             = null
    destination_ipv6_cidr_block        = null
    nat_gateway_id         = null
    network_interface_id   = null
    transit_gateway_id     = null
    vpc_peering_connection_id = aws_vpc_peering_connection.resource_stg_prd_peering.id
    
    # lifecycle {
    #   ignore_changes =  all 
    # }
}

