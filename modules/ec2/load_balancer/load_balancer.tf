variable "master" {}
variable "conf" {}
variable "app" {}
variable "app_name" {}
variable "my_target_group_arn" {}



data "aws_lb" "my_lb" {
  name = "${var.conf.lane}-${var.app.lb_connect}-LB"
}

data "aws_lb_listener" "my_lb_listner" {
  load_balancer_arn = data.aws_lb.my_lb.arn
  port              = var.app.lb_connect == "public" ? "443" : "80"
}


resource "aws_lb_listener_rule" "System-lb_Rule" {
  action {
    order            = "1"
    target_group_arn = var.my_target_group_arn
    type             = "forward"
  }

  condition {
    host_header {
      //values = [(var.conf.lane == "pr" ? "${var.app_name}.${var.app.domain}":"${var.conf.lane}-${var.app_name}.${var.app.domain}")]
      values = [ "${var.conf.lane}-${var.app_name}.${var.app.domain}" ]
      //values = [var.conf.lb_header]
    }
  }
  listener_arn = data.aws_lb_listener.my_lb_listner.arn
  //listener_arn = var.conf.lb_listner_arn
}



