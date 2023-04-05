variable "master" {}
variable "infa" {}
variable "my_vpc_id" {}


//####################################################
//adm
//###################################################
data "aws_vpc" "data_adm_vpc" {
  tags   = {
    Name = "${var.master.adminlane}-VPC"
  }
}

data "aws_route_table" "resource_route_table_adm" {
  vpc_id = data.aws_vpc.data_adm_vpc.id
  tags   = {
    Name = "${var.master.adminlane}-RT"
  }
}

data "aws_route_table" "resource_route_table_lane" {
  vpc_id = var.my_vpc_id
  tags   = {
    Name = "${var.infa.lane}-RT"
  }
}


//////////////////////////////////////////////////
//adm<->lane
resource "aws_vpc_peering_connection" "resource_adm_lane_peering" {
  accepter {
    # allow_classic_link_to_remote_vpc = "false"
    allow_remote_vpc_dns_resolution  = "false"
    # allow_vpc_to_remote_classic_link = "false"
  }

  peer_owner_id = var.master.aws_account_id
  peer_vpc_id   = var.my_vpc_id
  auto_accept = "true"

  requester {
    # allow_classic_link_to_remote_vpc = "false"
    allow_remote_vpc_dns_resolution  = "false"
    # allow_vpc_to_remote_classic_link = "false"
  }

  tags = {
    Name = "adm<->${var.infa.lane}"
  }

  tags_all = {
    Name = "adm<->${var.infa.lane}"
  }

  vpc_id = data.aws_vpc.data_adm_vpc.id
}

resource "aws_route" "resource_route_adm_lane" {
    route_table_id = data.aws_route_table.resource_route_table_lane.id
    destination_cidr_block             = data.aws_vpc.data_adm_vpc.cidr_block
    egress_only_gateway_id = null
    gateway_id             = null
    destination_ipv6_cidr_block        = null
    nat_gateway_id         = null
    network_interface_id   = null
    transit_gateway_id     = null
    vpc_peering_connection_id = aws_vpc_peering_connection.resource_adm_lane_peering.id
    
    lifecycle {
      ignore_changes =  all 
    }
}
resource "aws_route" "resource_route_lane_adm" {
    route_table_id = data.aws_route_table.resource_route_table_adm.id
    destination_cidr_block             = var.infa.vpc_cidr_block
    egress_only_gateway_id = null
    gateway_id             = null
    destination_ipv6_cidr_block        = null
    nat_gateway_id         = null
    network_interface_id   = null
    transit_gateway_id     = null
    vpc_peering_connection_id = aws_vpc_peering_connection.resource_adm_lane_peering.id
    
    lifecycle {
      ignore_changes =  all 
    }
}






