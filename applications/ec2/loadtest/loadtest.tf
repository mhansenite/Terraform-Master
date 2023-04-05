
variable "masterMain" {}
variable "loadtest_vars" {}
variable "gl_vars" {}

provider "aws" {
    region = "${var.masterMain.region}"
    profile = "${var.masterMain.profile}"
}


module loadtest {
    for_each = {
    #"load_runner1" = "1",
   # "load_runner2" = "2"
}
    source = "./loadtest/"
    masterMain = var.masterMain
    app = var.loadtest_vars
    app_name = "${var.loadtest_vars.app_name}-${each.value}"
    conf = var.gl_vars
}




