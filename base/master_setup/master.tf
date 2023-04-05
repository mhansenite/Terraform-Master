
variable "masterMain" {}
variable "adm_vars" {}
variable "tst_vars" {}
variable "prd_vars" {}
variable "stg_vars" {}

provider "aws" {
  region = "${var.masterMain.region}"
    profile = "${var.masterMain.profile}"
}


module "master_setup_route53" {
   source = "./route53"
   master = var.masterMain
}

