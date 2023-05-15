variable "masterMain" {}
variable "vpn_vars" {}
variable "adm_vars" {}

provider "aws" {
    region = "${var.masterMain.region}"
    profile = "${var.masterMain.profile}"
}


module "vpn" {
    source = "../../../modules/ec2/"
    masterMain = var.masterMain
    app = var.vpn_vars
    app_name = var.vpn_vars.app_name
    conf = var.adm_vars
}




