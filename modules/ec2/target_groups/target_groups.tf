variable "master" {}
variable "conf" {}
variable "app" {}
variable "app_name" {}
variable "my_ec2_instance_id" {}


data "aws_vpc" "my_vpc" {
  filter {
  name = "tag:Name"
  values = ["${var.conf.lane}-VPC"]
  }
}

resource "aws_lb_target_group" "resource_target_group" {
  deregistration_delay = "300"
  tags = {
    env = var.conf.lane
    use = var.app.app_use
  }

  health_check {
    enabled             = "true"
    healthy_threshold   = "2"
    interval            = "30"
    matcher             = var.app.tg_match
    path                = var.app.hc_path
    port                = var.app.external_port
    protocol            = "HTTP"
    timeout             = "5"
    unhealthy_threshold = "2"
  }

  load_balancing_algorithm_type = "round_robin"
  name                          = "${var.conf.lane}-${var.app_name}-TG"
  port                          = var.app.tg_port
  protocol                      = var.app.tg_proto
  protocol_version              = var.app.tg_proto_version
  slow_start                    = "0"

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }

  target_type = "instance"
  vpc_id      = data.aws_vpc.my_vpc.id
}


resource "aws_lb_target_group_attachment" "resource_attatchment" {
  target_group_arn = aws_lb_target_group.resource_target_group.arn
  target_id        = var.my_ec2_instance_id
  port             = var.app.external_port
}

output "my_target_group_arn" {
  description = "ARN of target group"
  value       = aws_lb_target_group.resource_target_group.arn
}