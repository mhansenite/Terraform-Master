variable "masterMain" {}
variable "adm_vars" {}

provider "aws" {
  region = "${var.masterMain.region}"
  profile = "${var.masterMain.profile}"
}

module "adm_infa" {
    source = "../../modules/infrastructure/"
    masterMain = var.masterMain
    infaMain = var.adm_vars
}

