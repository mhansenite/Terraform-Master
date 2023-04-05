
output "my_vpc" {
  value = module.vpc.my_vpc
}

output "prefix_list_db" {
  value = module.prefix_list.prefix_list_db
}

output "prefix_list_app" {
 value =  module.prefix_list.prefix_list_app

}

output "my_subnets_app" {
  value = module.subnet.my_subnets_app
}

output "my_subnets_db" {
  value = module.subnet.my_subnets_db
}

output "my_public_listener" {
  value = module.load_balancers.my_public_listener
}

output "my_private_listener" {
  value = module.load_balancers.my_public_listener
}

