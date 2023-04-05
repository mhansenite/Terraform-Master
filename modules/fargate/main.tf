variable "masterMain" {}
variable "confMain" {}
variable "appMain" {}
variable "app_name" {}


module "security_groups" {
    source = "./security_groups"
    master=var.masterMain
    conf = var.confMain
    app = var.appMain
    app_name = var.app_name
}

module "target_groups" {
    source = "./target_groups"
    master=var.masterMain
    conf = var.confMain
    app = var.appMain
    app_name = var.app_name
}

module "ecs" {
    source = "./ecs"
    master=var.masterMain
    conf = var.confMain
    app = var.appMain
    my_target_group_arn = module.target_groups.my_target_group_arn
    my_security_group_id = module.security_groups.my_security_group_id
    app_name = var.app_name
}



module "load_balancer" {
    source = "./load_balancer"
    master=var.masterMain
    conf = var.confMain
    app = var.appMain
    my_target_group_arn = module.target_groups.my_target_group_arn
    app_name = var.app_name
}
module "cloud_watch" {
    depends_on = [
    module.target_groups,
    module.load_balancer,
    module.ecs]

    source = "./cloud_watch"
    master=var.masterMain
    conf = var.confMain
    app = var.appMain
    app_name = var.app_name
}
module "route53" {
    source = "./route53"
    master=var.masterMain
    conf = var.confMain
    app = var.appMain
    app_name = var.app_name
}