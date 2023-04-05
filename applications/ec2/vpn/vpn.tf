variable "masterMain" {}
variable "vpn_vars" {}
variable "admin_vars" {}

provider "aws" {
    region = "${var.masterMain.region}"
    profile = "${var.masterMain.profile}"
}


module "vpn" {
    source = "../../../modules/ec2/"
    masterMain = var.masterMain
    app = var.vpn_vars
    app_name = var.vpn_vars.app_name
    conf = var.admin_vars
}




