variable "master" {}
variable "infa" {}
variable "my_subnets_app" {}
variable "my_vpc_id" {}

// 
resource "aws_security_group" "resource_lb_security_private" {
  lifecycle { ignore_changes = all }
  description = "Security group for Load Balancer"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    description     = "all"
    from_port       = 80
    cidr_blocks =  ["10.0.0.0/8"]
    protocol        = "tcp"
    self            = "false"
    to_port         = 80
  }

  ingress {
    description     = "all"
    from_port       = 443
    cidr_blocks =  ["10.0.0.0/8"] 
    protocol        = "tcp"
    self            = "false"
    to_port         = 443
  }

  ingress {
    description     = "all"
    from_port       = 8123
    cidr_blocks =  ["10.0.0.0/8"]
    protocol        = "tcp"
    self            = "false"
    to_port         = 8123
  }

  ingress {
    description     = "all"
    from_port       = 7171
    cidr_blocks =  ["10.0.0.0/8"]
    protocol        = "tcp"
    self            = "false"
    to_port         = 7171
  }

  ingress {
    description     = "all"
    from_port       = 8080
    cidr_blocks =  ["10.0.0.0/8"]
    protocol        = "tcp"
    self            = "false"
    to_port         = 8080
  }

  name = "${var.infa.lane}-lb-private-Access-SG"

  tags = {
    Name = "${var.infa.lane}-lb-private-Access-SG"
  }

  tags_all = {
    Name = "${var.infa.lane}-lb-private-Access-SG"
  }
  vpc_id = var.my_vpc_id
}

resource "aws_security_group" "resource_lb_security_public" {
  lifecycle { ignore_changes = all }
  description = "Security group for Load Balancer"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    description     = "public"
    from_port       = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol        = "tcp"
    self            = "false"
    to_port         = 80
  }

  ingress {
    description     = "public"
    from_port       = 443
    cidr_blocks = ["0.0.0.0/0"]
    protocol        = "tcp"
    self            = "false"
    to_port         = 443
  }

  name = "${var.infa.lane}-lb-public-Access-SG"

  tags = {
    Name = "${var.infa.lane}-lb-public-Access-SG"
  }

  tags_all = {
    Name = "${var.infa.lane}-lb-public-Access-SG"
  }

  vpc_id = var.my_vpc_id
}


output "my_lb_security_group_private" {
  description = "ARN of target group"
  value       = aws_security_group.resource_lb_security_private
}

output "my_lb_security_group_public" {
  description = "ARN of target group"
  value       = aws_security_group.resource_lb_security_public
}


resource "aws_lb" "resource_lb_private" {
  lifecycle { ignore_changes = all }
  desync_mitigation_mode     = "defensive"
  drop_invalid_header_fields = "false"
  enable_deletion_protection = "false"
  enable_http2               = "true"
  enable_waf_fail_open       = "false"
  idle_timeout               = "300"
  internal                   = "true"
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  name                       =  "${var.infa.lane}-private-LB"
  security_groups            =  [ aws_security_group.resource_lb_security_private.id ]
  subnets = var.my_subnets_app
}

resource "aws_lb" "resource_lb_public" {
  lifecycle { ignore_changes = all }
  desync_mitigation_mode     = "defensive"
  drop_invalid_header_fields = "false"
  enable_deletion_protection = "false"
  enable_http2               = "true"
  enable_waf_fail_open       = "false"
  idle_timeout               = "300"
  internal                   = "false"
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  name                       =  "${var.infa.lane}-public-LB"
  security_groups            = [ aws_security_group.resource_lb_security_public.id ]

  subnets = var.my_subnets_app
}

resource "aws_lb_listener" "resource_lb_listener_private" {
  lifecycle { ignore_changes = all }
  load_balancer_arn = aws_lb.resource_lb_private.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "The Application you are looking for is still being set up Please Try again later"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener" "resource_lb_listener_private_clickhouse" {
  lifecycle { ignore_changes = all }
  load_balancer_arn = aws_lb.resource_lb_private.arn
  port              = "8123"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "The Application you are looking for is still being set up Please Try again later"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener" "resource_lb_listener_private_clickhouse_backup" {
  lifecycle { ignore_changes = all }
  load_balancer_arn = aws_lb.resource_lb_private.arn
  port              = "7171"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "The Application you are looking for is still being set up Please Try again later"
      status_code  = "200"
    }
  }
}
resource "aws_lb_listener" "resource_lb_listener_private_gRPC" {
  lifecycle { ignore_changes = all }
  certificate_arn = "${var.master.certificate_arn}"
  load_balancer_arn = aws_lb.resource_lb_private.arn
  port              = "8080"
  protocol          = "HTTPS"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "The Application you are looking for is still being set up Please Try again later"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener" "resource_lb_listener_public_redirect" {
  lifecycle { ignore_changes = all }
  load_balancer_arn = aws_lb.resource_lb_public.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_lb_listener" "resource_lb_listener_public" {
  lifecycle { ignore_changes = all }
  certificate_arn = "${var.master.certificate_arn}"
  load_balancer_arn = aws_lb.resource_lb_public.arn
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "The Application you are looking for is still being set up Please Try again later"
      status_code  = "200"
    }
  }
}

output "my_public_listener" {
  value = aws_lb_listener.resource_lb_listener_public
}

output "my_private_listener" {
  value = aws_lb_listener.resource_lb_listener_private
}