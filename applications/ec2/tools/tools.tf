variable "masterMain" {}
variable "tools_vars" {}
variable "admin_vars" {}

provider "aws" {
    region = "${var.masterMain.region}"
    profile = "${var.masterMain.profile}"
}


module "tools" {
    source = "../../../modules/ec2/"
    masterMain = var.masterMain
    app = var.tools_vars
    app_name = var.tools_vars.app_name
    conf = var.admin_vars
}




