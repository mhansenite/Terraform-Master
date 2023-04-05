variable "masterMain" {}
variable "stg_vars" {}
variable "tst_vars" {}
variable "prd_vars" {}
variable "ws_vars" {}

provider "aws" {
    region = "${var.masterMain.region}"
    profile = "${var.masterMain.profile}"
}

module "base_ws"{
    source = "../../../modules/base"
    masterMain = var.masterMain
    appMain = var.ws_vars
    app_name = var.ws_vars.app_name
}



module "app_ws_tst" {
    source = "../../../modules/fargate/"
    masterMain = var.masterMain
    appMain = var.ws_vars
    confMain = var.tst_vars
    app_name = var.ws_vars.app_name
}

module "app_ws_stg" {
    source = "../../../modules/fargate/"
    masterMain = var.masterMain
    appMain = var.ws_vars
    confMain = var.stg_vars
    app_name = var.ws_vars.app_name
}

module "app_ws_prd" {
    source = "../../../modules/fargate/"
    masterMain = var.masterMain
    appMain = var.ws_vars
    confMain = var.prd_vars
    app_name = var.ws_vars.app_name
}




