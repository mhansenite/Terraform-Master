variable "master" {}
variable "infa" {}
variable "my_vpc" {} 
variable "my_igw" {}
variable "my_rt_id" {}


resource "aws_default_route_table" "resource_defualt_table" {
  default_route_table_id = var.my_rt_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.my_igw.id
  }

  tags = {
    Name = "${var.infa.lane}-RT"
  }
      lifecycle {
      ignore_changes =  all 
    }  
}
