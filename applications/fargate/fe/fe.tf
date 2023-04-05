variable "masterMain" {}
variable "stg_vars" {}
variable "tst_vars" {}
variable "prd_vars" {}
variable "fe_vars" {}

provider "aws" {
    region = "${var.masterMain.region}"
    profile = "${var.masterMain.profile}"
}

module "base_fe"{
    source = "../../../modules/base"
    masterMain = var.masterMain
    appMain = var.fe_vars
    app_name = var.fe_vars.app_name
}



module "app_fe_tst" {
    source = "../../../modules/fargate/"
    masterMain = var.masterMain
    appMain = var.fe_vars
    confMain = var.tst_vars
    app_name = var.fe_vars.app_name
}

module "app_fe_stg" {
    source = "../../../modules/fargate/"
    masterMain = var.masterMain
    appMain = var.fe_vars
    confMain = var.stg_vars
    app_name = var.fe_vars.app_name
}

module "app_fe_prd" {
    source = "../../../modules/fargate/"
    masterMain = var.masterMain
    appMain = var.fe_vars
    confMain = var.prd_vars
    app_name = var.fe_vars.app_name
}




