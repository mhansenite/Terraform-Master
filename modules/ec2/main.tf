variable "masterMain" {}
variable "conf" {}
variable "app" {}
variable "app_name" {}

locals{
  rt53_ip = var.app.create_lb == "false" ? 1 : 0
  rt53_lb = var.app.create_lb == "true" ? 1 : 0
}

module "security_groups" {
    source = "./security_groups"
    master=var.masterMain
    conf = var.conf
    app = var.app
    app_name = var.app_name
}

module "target_groups" {
    source = "./target_groups"
    master=var.masterMain
    conf = var.conf
    app = var.app
    app_name = var.app_name 
    my_ec2_instance_id = module.ec2.my_ec2_instance.id

}

module "ec2" {
    source = "./ec2"
    master=var.masterMain
    conf = var.conf
    app = var.app
    app_name = var.app_name
    my_security_group = module.security_groups.my_security_group_id

}

module "route53" {
  count = local.rt53_lb
    source = "./route53_lb"
    master=var.masterMain
    app = var.app
    app_name = var.app_name
    conf = var.conf
   }

module "route53_ip" {
  count = local.rt53_ip
  source = "./route53_host"
  master=var.masterMain
  app = var.app
  app_name = var.app_name
  conf = var.conf
  my_ec2_instance = module.ec2.my_ec2_instance
}

module "load_balancer" {
    source = "./load_balancer"
    master=var.masterMain
    conf = var.conf
    app = var.app
    my_target_group_arn = module.target_groups.my_target_group_arn
    app_name = var.app_name
}

module "cloud_watch" {
  depends_on = [
    module.ec2,
    module.target_groups,
    module.load_balancer
  ]
  source = "./cloud_watch"
  master=var.masterMain
  conf = var.conf
  app = var.app
  app_name = var.app_name

}
#output "my_zone" {
#  value       = module.route53.my_zone
#}
#
#output "my_lb" {
#  value       = module.route53.my_lb
#}