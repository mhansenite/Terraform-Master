variable "master" {}
variable "conf" {}
variable "app" {}
variable "app_name" {}
variable "my_security_group" {}

data "aws_vpc" "my_vpc" {
  filter {
  name = "tag:Name"
  values = ["${var.conf.lane}-VPC"]

  }

}

data "aws_subnets" "my_subnets" {
  filter {
    name   = "tag:Name"
    values = [ "${var.conf.lane}-AP-Zone-1-SN" ]

  }
}

data "template_file" "init" {
  template = "${file("${var.app.startup_script}")}"
  vars = {
    app_name = "${var.app_name}"
  }
}

resource "aws_instance" "resource_ec2_instance" {
  lifecycle { ignore_changes = [user_data] }
  ami           = var.app.ami_id
  instance_type = var.app.ec2_size
  associate_public_ip_address = "true"
  vpc_security_group_ids = ["${var.my_security_group}"]
  subnet_id         = data.aws_subnets.my_subnets.ids[0]
  key_name = "Neo-Admin"
  //user_data = "${file("${var.app.startup_script}")}"
  iam_instance_profile = "NEO-CloudWatchAgentServerRole"
  user_data  = data.template_file.init.rendered
  
    root_block_device {
    volume_size           = "${var.app.storage}"
    delete_on_termination = "true"
    }

  tags = {
    Name = "${var.conf.lane}-${var.app_name}"
    env = var.conf.lane
    use = var.app.app_use
  }
}

output "my_ec2_instance" {
  value = aws_instance.resource_ec2_instance
  
}
# output "my_userdata" {
#   value = aws_instance.resource_ec2_instance
  
# }