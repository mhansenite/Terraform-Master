variable "masterMain" {}
variable "appMain" {}
variable "app_name" {}


module "ecr" {
    source = "./ecr"
    master=var.masterMain
    app = var.appMain
    app_name = var.app_name
}