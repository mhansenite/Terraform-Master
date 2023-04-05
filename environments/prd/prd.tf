

variable "masterMain" {}
variable "prd_vars" {}
provider "aws" {
  region = "${var.masterMain.region}"
  profile = "${var.masterMain.profile}"
}

module "prd_infa" {
    source = "../../modules/infrastructure/"
    masterMain = var.masterMain
    infaMain = var.prd_vars   
}

#data "aws_vpc_peering_connections" "whatdoweget" {
#  tags = {
#    name = "test<->stage"
##  }

#}
#output "my_vpcid" {
## value       = data.aws_vpc_peering_connections.whatdoweget.ids
#}