variable "masterMain" {}
variable "tst_vars" {}
provider "aws" {
  region = "${var.masterMain.region}"
  profile = "${var.masterMain.profile}"
}

module "tst_infa" {
    source = "../../modules/infrastructure/"
    masterMain = var.masterMain
    infaMain = var.tst_vars   
}

#data "aws_vpc_peering_connections" "whatdoweget" {
#  tags = {
#    name = "test<->stage"
##  }

#}
#output "my_vpcid" {
## value       = data.aws_vpc_peering_connections.whatdoweget.ids
#}