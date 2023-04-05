variable "masterMain" {}
variable "conf" {}
variable "app" {}
variable "app_name" {}


module "security_groups" {
    source = "../../../../modules/ec2/security_groups"
    master=var.masterMain
    conf = var.conf
    app = var.app
    app_name = var.app_name
}

module "ec2" {
    source = "../../../../modules/ec2/ec2"
    master=var.masterMain
    conf = var.conf
    app = var.app
    app_name = var.app_name
    my_security_group = module.security_groups.my_security_group_id
}

module "route53" {
  depends_on = [
    module.ec2
  ]
    source = "../../../../modules/ec2/route53_host"
    master=var.masterMain
    conf = var.conf
    app = var.app
    app_name = var.app_name
    my_ec2_instance = module.ec2.my_ec2_instance
   }

module "cloud_watch" {
  depends_on = [
    module.ec2
  ]
    source = "../../../../modules/ec2/cloud_watch"
    master=var.masterMain
    conf = var.conf
    app = var.app
    app_name = var.app_name
} 


# output "my_userdata" {
#   value = module.ec2.my_userdata
  
# }

# output "my_ec2_instance" {
#  value = module.np_blue_ec2.my_ec2_instance
 
# }
#output "my_ec2_instance1" {
#  value = module.dv_cloud_watch.my_ec2_instance1
#  
#}