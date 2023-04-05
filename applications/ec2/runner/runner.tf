
variable "masterMain" {}
variable "runner_vars" {}
variable "gl_vars" {}

provider "aws" {
    region = "${var.masterMain.region}"
    profile = "${var.masterMain.profile}"
}


module "runner" {
    for_each = {
    "GH_runner1" = "1"
} 
    #count = 2
    source = "./runner/"
    masterMain = var.masterMain
    app = var.runner_vars
    app_name = "${var.runner_vars.app_name}-${each.value}"
    conf = var.gl_vars
}




