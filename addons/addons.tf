
variable "masterMain" {}
variable "adm_vars" {}
variable "tst_vars" {}
variable "prd_vars" {}
variable "stg_vars" {}

provider "aws" {
    region = "${var.masterMain.region}"
    profile = "${var.masterMain.profile}"
}

module "addon_lambda" {
    source = "./lambda"
    master = var.masterMain

}

module "addon_peering" {
    source = "./peering"
    masterMain = var.masterMain
    prd_vars = var.prd_vars
    stg_vars = var.stg_vars
}
