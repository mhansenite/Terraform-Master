variable "masterMain" {}
variable "infaMain" {}

#module "iam" {
#    source = "./iam"
#    master=var.masterMain
#    infa = var.infaMain
#}

module "vpc" {
    source = "./vpc"
    master=var.masterMain
    infa = var.infaMain
}

module "routes" {
    source = "./routes"
    master=var.masterMain
    infa = var.infaMain
    my_vpc = module.vpc.my_vpc
    my_igw = module.vpc.my_igw
    my_rt_id = module.vpc.my_main_route_table
}


module "master_setup_route53" {
   source = "./route53"
   master = var.masterMain
   my_vpc_id = module.vpc.my_vpc.id
   
}

module "subnet" {
    source = "./subnet"
    master=var.masterMain
    infa = var.infaMain
    my_vpc = module.vpc.my_vpc
}

module "prefix_list" {
    source = "./prefix_list"
    master=var.masterMain
    infa = var.infaMain
   }


module "load_balancers" {
    source = "./load_balancer"
    master=var.masterMain
    infa = var.infaMain
    my_vpc_id = module.vpc.my_vpc.id
    my_subnets_app = module.subnet.my_subnets_app
   }

# module "lambda" {
#     source = "./lambda"
#     master=var.masterMain
#     infa = var.infaMain
#    }


module "vpc_peering" {
    count = var.infaMain.lane == var.masterMain.adminlane ? 0 : 1
    depends_on = [module.vpc]
    source = "./peering/"
    master=var.masterMain
    infa = var.infaMain
    my_vpc_id = module.vpc.my_vpc.id
}

#output "my_vpcid" {
#  value       = module.route53.my_vpcid
#}





